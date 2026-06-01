const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

/**
 * TRIGGER 1: Lecturer Burnout Monitor
 * Automatically runs whenever an enrollment document modifies.
 * If a student's burnout index hits 70%+, it identifies the course lecturer and sends an FCM push payload.
 */
exports.notifyLecturerOnBurnout = functions.firestore
    .document('enrollments/{enrollmentId}')
    .onUpdate(async (change, context) => {
        const afterData = change.after.data();
        const beforeData = change.before.data();

        // Check if the burnout index crossed the 0.70 threshold mark
        if (afterData.burnoutIndex >= 0.70 && beforeData.burnoutIndex < 0.70) {
            const targetClassName = afterData.classId;
            const targetStudentUid = afterData.studentId;

            try {
                // 1. Resolve student's clear human display profile name string
                const studentProfileSnapshot = await admin.firestore().collection('users').doc(targetStudentUid).get();
                const studentNameStringValue = studentProfileSnapshot.exists ? studentProfileSnapshot.data().name : "A student";

                // 2. Discover the target managing Lecturer UID linked to the target class
                const matchingClassQuerySnapshot = await admin.firestore().collection('classes')
                    .where('name', '==', targetClassName).limit(1).get();

                if (!matchingClassQuerySnapshot.empty) {
                    const assignedLecturerUid = matchingClassQuerySnapshot.docs[0].data().lecturerId;

                    // 3. Extract the Lecturer's real-time hardware device routing token
                    const lecturerProfileSnapshot = await admin.firestore().collection('users').doc(assignedLecturerUid).get();
                    
                    if (lecturerProfileSnapshot.exists && lecturerProfileSnapshot.data().fcmToken) {
                        const destinationToken = lecturerProfileSnapshot.data().fcmToken;

                        const messagePayload = {
                            notification: {
                                title: `🔥 Critical Burnout Alert — ${studentNameStringValue}`,
                                body: `${studentNameStringValue} has hit a critical academic strain index of ${(afterData.burnoutIndex * 100).toFixed(0)}% in ${targetClassName}.`,
                            },
                            data: {
                                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                                navigationRoute: '/lecturer_alerts',
                            }
                        };

                        // Push the notification tray block directly to the lecturer's phone or browser window
                        await admin.messaging().sendToDevice(destinationToken, messagePayload);
                        console.log(`Successfully pushed burnout alert routing to Lecturer UID: ${assignedLecturerUid}`);
                    }
                }
            } catch (error) {
                console.error("Failed to execute background lecturer burnout alert delivery rule:", error);
            }
        }
    });

/**
 * TRIGGER 2: Student Personal Burnout Alert
 * Warns the student directly if their stress metrics enter a critical zone.
 */
exports.notifyStudentOnSelfBurnout = functions.firestore
    .document('enrollments/{enrollmentId}')
    .onUpdate(async (change, context) => {
        const afterData = change.after.data();
        const beforeData = change.before.data();

        if (afterData.burnoutIndex >= 0.75 && beforeData.burnoutIndex < 0.75) {
            const studentUid = afterData.studentId;

            try {
                const profileSnapshot = await admin.firestore().collection('users').doc(studentUid).get();
                if (profileSnapshot.exists && profileSnapshot.data().fcmToken) {
                    const studentDeviceToken = profileSnapshot.data().fcmToken;

                    const messagePayload = {
                        notification: {
                            title: '⚠️ Workload Warning Threshold Met',
                            body: `Your tracking matrix shows exhaustion parameters at ${(afterData.burnoutIndex * 100).toFixed(0)}%. Consider managing your task schedule boundaries.`,
                        },
                        data: {
                            click_action: 'FLUTTER_NOTIFICATION_CLICK',
                        }
                    };

                    await admin.messaging().sendToDevice(studentDeviceToken, messagePayload);
                }
            } catch (error) {
                console.error("Failed to process self student burnout warning token packet:", error);
            }
        }
    });

/**
 * TRIGGER 3: Task Assignment Push Notifications
 * Notifies all students enrolled in a class when the lecturer updates the course tasks matrix.
 */
exports.notifyStudentsOnTaskAssignment = functions.firestore
    .document('classes/{classId}')
    .onUpdate(async (change, context) => {
        const tasksListAfter = change.after.data().initialTasks || [];
        const tasksListBefore = change.before.data().initialTasks || [];

        // Identify if a new task element block was added to the module array
        if (tasksListAfter.length > tasksListBefore.length) {
            const moduleName = change.after.data().name;
            const newlyCreatedTaskElement = tasksListAfter[tasksListAfter.length - 1];
            const displayTitleStringValue = newlyCreatedTaskElement.title || "New Coursework Assignment";

            try {
                // 1. Gather all active student enrollments for this class identifier
                const activeEnrollmentsSnapshot = await admin.firestore().collection('enrollments')
                    .where('classId', '==', moduleName).get();

                if (!activeEnrollmentsSnapshot.empty) {
                    const studentIdArray = activeEnrollmentsSnapshot.docs.map(doc => doc.data().studentId);
                    const targetedDeviceTokensList = [];

                    // 2. Aggregate corresponding token indices from the root users directory mapping files
                    for (const uid of studentIdArray) {
                        const userProfileSnapshot = await admin.firestore().collection('users').doc(uid).get();
                        if (userProfileSnapshot.exists && userProfileSnapshot.data().fcmToken) {
                            targetedDeviceTokensList.push(userProfileSnapshot.data().fcmToken);
                        }
                    }

                    // 3. Multicast send messaging vectors simultaneously to all target student phones
                    if (targetedDeviceTokensList.length > 0) {
                        const messagePayload = {
                            notification: {
                                title: `📚 New Task Assigned: ${moduleName}`,
                                body: `A new tracking assignment requirement has been published: "${displayTitleStringValue}"`,
                            },
                            data: {
                                click_action: 'FLUTTER_NOTIFICATION_CLICK',
                            }
                        };

                        await admin.messaging().sendToDevice(targetedDeviceTokensList, messagePayload);
                        console.log(`Dispatched course assignment notices across ${targetedDeviceTokensList.length} device tokens.`);
                    }
                }
            } catch (error) {
                console.error("Failed to run multicast distribution updates for task assignments:", error);
            }
        }
    });
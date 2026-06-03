import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  // Put your actual Google AI Studio key here
  static const String _apiKey = 'AIzaSyDde40Mgc-MTNBp1OwIXY0EhcTxLLLgk1Q';

  /// Generates a structured personalized weekly study plan from the student's metrics
  static Future<Map<String, dynamic>> generateStudyPlan({
    required List<Map<String, dynamic>> tasks,
    required List<String> enrolledSubjects,
    required String studyStart,
    required String studyEnd,
    required List<String> blockedSlots,
    required String burnoutLevel,
    required String startDateIso,
  }) async {

    // 1. Initialize the target generation model
    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      // Force the engine to output strict JSON compliance structure layouts
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.3, // Lower temperature keeps scheduling rules highly consistent
      ),
    );

    // 2. Define the exact system prompt rules and the expected output schema
    const String systemInstruction = '''
You are a smart student study planner. Generate a full 7-day weekly study schedule personalised to the student's real context.

You must ALWAYS respond with ONLY a valid JSON object. No explanation, no markdown, no preamble. Just raw JSON.

---

CONTEXT YOU WILL RECEIVE:
- tasks: pending assignments/tasks with estimated hours, subject, priority, and optional due date
- enrolled_subjects: all subjects the student is enrolled in (use these for revision sessions when no tasks exist)
- study_window: the student's preferred study hours (start and end time)
- blocked_slots: time slots already taken (classes, lectures, personal commitments) — never schedule study here
- burnout_level: current burnout state — "low", "moderate", "high", or "critical"
- start_date: Monday of the current week (ISO format)

---

SCHEDULING RULES:
- Only schedule within the study_window (start to end time)
- Never place study blocks during blocked_slots
- Prioritize tasks by: inProgress > high priority > due date ascending > medium > low
- If a task has a due date, complete all its study sessions before or on that date
- Split large tasks (>2hr) across multiple days, max 90 min per session per subject per day
- After every 90 min study block, insert a 15-min breakSlot
- Insert a 45-min lunch breakSlot at 12:00 on days with sessions
- Saturdays and Sundays have NO blocked slots — use them for catch-up or revision

BURNOUT ADAPTATION:
- "low": normal scheduling, up to 6hr study per day
- "moderate": cap at 4hr study per day, add extra breaks
- "high": cap at 3hr study per day, lighter sessions, add motivational block titles
- "critical": cap at 2hr study per day, mostly revision and rest, gentle titles only

WHEN NO TASKS EXIST (or after all tasks are scheduled):
- Fill remaining slots with revision sessions for enrolled_subjects
- Rotate subjects across days — don't put the same subject twice in one day
- Use titles like "Revise [Subject] notes", "Practice [Subject] problems", "Review week's [Subject] material"

---

BLOCK TYPE RULES:
- "study" for all study and revision sessions
- "breakSlot" for all breaks
- "blocked" for fixed commitments from blocked_slots
- Never use any other type value

BLOCK STATUS RULES:
- "toDo" for future sessions
- "inProgress" for the current active session
- "completed" for past sessions
- "dueSoon" for sessions within 30 minutes of now
- "none" for breaks and blocked slots

TIME FORMAT: 24hr "HH:MM" only. Never use AM/PM.

---

RESPONSE SCHEMA (return this exact structure, nothing else):
{
  "last_updated": "2025-01-01T00:00:00.000",
  "days": [
    {
      "date": "2025-01-01",
      "blocks": [
        {
          "title": "Write use case diagrams",
          "subject": "CT124 System Proposal",
          "start_time": "09:00",
          "duration_minutes": 90,
          "type": "study",
          "status": "toDo"
        },
        {
          "title": "Short break",
          "subject": null,
          "start_time": "10:30",
          "duration_minutes": 15,
          "type": "breakSlot",
          "status": "none"
        }
      ]
    }
  ],
  "burnout_alert": {
    "risk_level": "low",
    "triggered": false,
    "reason": "Daily study load is within safe limits with regular breaks."
  }
}
''';

    // 3. Format incoming workspace metrics to the structured user payload schema
    final Map<String, dynamic> userRequestMap = {
      'tasks':             tasks,
      'enrolled_subjects': enrolledSubjects,
      'study_window': {
        'start': studyStart,
        'end':   studyEnd,
      },
      'blocked_slots': blockedSlots,
      'burnout_level': burnoutLevel,
      'start_date':    startDateIso,
    };

    // Construct the explicit multi-part context prompt array
    final prompt = [
      Content.text('$systemInstruction\n\nUser Input data:\n${jsonEncode(userRequestMap)}')
    ];

    try {
      final response = await model.generateContent(prompt);
      final String? rawJsonString = response.text;

      if (rawJsonString != null && rawJsonString.isNotEmpty) {
        // Parse the raw response directly to a clean Dart map layout structure
        return jsonDecode(rawJsonString) as Map<String, dynamic>;
      } else {
        throw Exception('The AI generation service returned an empty schedule response.');
      }
    } catch (e) {
      throw Exception('Failed to finalize AI study plan optimization: $e');
    }
  }
}
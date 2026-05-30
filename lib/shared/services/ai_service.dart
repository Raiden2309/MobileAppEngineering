import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  // Put your actual Google AI Studio key here
  static const String _apiKey = 'AIzaSyDde40Mgc-MTNBp1OwIXY0EhcTxLLLgk1Q';

  /// Generates a structured personalized weekly study plan from the student's metrics
  static Future<Map<String, dynamic>> generateStudyPlan({
    required List<Map<String, dynamic>> subjects,
    required int availableHoursPerDay,
    required String startDateIso,
  }) async {

    // 1. Initialize the target generation model
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      // Force the engine to output strict JSON compliance structure layouts
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.3, // Lower temperature keeps scheduling rules highly consistent
      ),
    );

    // 2. Define the exact system prompt rules and the expected output schema
    const String systemInstruction = '''
You are a study schedule assistant. Your job is to generate personalized weekly study schedules and monitor for student burnout.

You must ALWAYS respond with ONLY a valid JSON object. No explanation, no markdown, no preamble. Just raw JSON.

---

BLOCK TYPE RULES:
- Use "study" for all study sessions
- Use "breakSlot" for all breaks (short and lunch)
- Use "blocked" for fixed commitments (classes, lectures)
- Never use any other type value

BLOCK STATUS RULES:
- Use "toDo" for all future sessions
- Use "inProgress" for the current active session
- Use "completed" for past sessions
- Use "dueSoon" for sessions within 30 minutes of starting
- Use "none" if status is not applicable (e.g. breaks, blocked)

TIME FORMAT RULES:
- All start_time values must be in 24hr format: "HH:MM" (e.g. "08:00", "13:30")
- Never use AM/PM

---

SCHEDULE RULES:
- Prioritize HIGH priority subjects in the morning (08:00–12:00)
- Assign MEDIUM priority subjects mid-day (13:00–17:00)
- Assign LOW priority subjects in the evening (18:00–20:00)
- Insert a 15-min breakSlot every 90 minutes of study
- Insert a 45-min lunch breakSlot at 12:00
- Never schedule more than 3 hours of the same subject per day
- If available_hours_per_day > 8, cap it at 8 and set burnout risk to "high"
- Weekends (Saturday, Sunday) may have lighter schedules or empty blocks

---

BURNOUT DETECTION RULES:
- "high": total daily study hours > 8, OR any single study block > 3 hours, OR no breaks scheduled
- "medium": total daily study hours between 6–8, OR fewer than 2 breaks per day
- "low": total daily study hours ≤ 6 with breaks distributed evenly

---

RESPONSE SCHEMA (return this exact structure, nothing else):
{
  "last_updated": "2025-01-01T00:00:00.000",
  "days": [
    {
      "date": "2025-01-01",
      "blocks": [
        {
          "title": "Review lecture notes",
          "subject": "Research Methods",
          "start_time": "08:00",
          "duration_minutes": 90,
          "type": "study",
          "status": "toDo"
        },
        {
          "title": "Short break",
          "subject": "Recommended",
          "start_time": "09:30",
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
  },
  "recommendations": [
    "Keep study sessions under 90 minutes before taking a break.",
    "Spread high-priority subjects across multiple mornings."
  ]
}
''';

    // 3. Format incoming workspace metrics to the structured user payload schema
    final Map<String, dynamic> userRequestMap = {
      'subjects': subjects,
      'available_hours_per_day': availableHoursPerDay,
      'start_date': startDateIso,
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
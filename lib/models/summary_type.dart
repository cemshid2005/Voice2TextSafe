/// Summary styles the user can request for a transcript. The original
/// transcript is never modified by a summary.
enum SummaryType {
  normal,
  professional,
  brief,
  bulletPoints;

  /// Shown in the UI.
  String get label => switch (this) {
        SummaryType.normal => 'Normal',
        SummaryType.professional => 'Professional',
        SummaryType.brief => 'Qısa',
        SummaryType.bulletPoints => 'Bullet-point',
      };

  /// Used inside AI prompts, in English, for reliable model behavior.
  String get promptInstruction => switch (this) {
        SummaryType.normal =>
          'Write a clear, neutral summary of the following text in a few sentences.',
        SummaryType.professional =>
          'Write a formal, professional-style summary of the following text, '
              'suitable for a business report.',
        SummaryType.brief =>
          'Summarize the following text in 1-2 short sentences, capturing only '
              'the core point.',
        SummaryType.bulletPoints =>
          'Summarize the following text as a concise bulleted list of the key '
              'points. Use "- " at the start of each line.',
      };
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/engagement_provider.dart';

class EngagementController {
  static void setFilter(BuildContext context, String key) {
    context.read<EngagementProvider>().setFilter(key);
  }
}
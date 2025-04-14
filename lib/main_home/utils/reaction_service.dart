import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';

class ReactionService {
  final ApiService _apiService = ApiService();

  // Load saved reactions from SharedPreferences
  Future<Map<String, dynamic>> loadSavedReactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedReactions = prefs.getString('user_reactions');

      if (savedReactions != null) {
        return json.decode(savedReactions);
      }
      return {};
    } catch (e) {
      print('Error loading saved reactions: ${e.toString()}');
      return {};
    }
  }

  // Save reactions to SharedPreferences
  Future<void> saveReactionsToLocal(Map<String, dynamic> reactions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_reactions', json.encode(reactions));
    } catch (e) {
      print('Error saving reactions: ${e.toString()}');
    }
  }

  // Toggle reaction - Add or remove based on current state
  Future<Map<String, dynamic>> toggleReaction(
      String postId,
      String reactionType,
      String userId,
      Map<String, dynamic> currentReactions
      ) async {
    Map<String, dynamic> reactions = Map.from(currentReactions);
    bool hasReaction = false;
    String? existingReactionId;

    // Check if user already has this reaction type on this post
    if (reactions.containsKey(postId)) {
      for (var reaction in reactions[postId]) {
        if (reaction['user_id'].toString() == userId &&
            reaction['type'] == reactionType) {
          hasReaction = true;
          existingReactionId = reaction['id'].toString();
          break;
        }
      }
    }

    try {
      if (hasReaction && existingReactionId != null) {
        // Remove existing reaction
        await _apiService.removeReaction(existingReactionId);

        // Update state to reflect removal
        if (reactions.containsKey(postId)) {
          reactions[postId] = reactions[postId].where((r) =>
          !(r['id'].toString() == existingReactionId)).toList();
        }

        // Save updated reactions to local storage
        await saveReactionsToLocal(reactions);
      } else {
        // Generate a temporary ID for the new reaction
        String tempId = DateTime.now().millisecondsSinceEpoch.toString();

        // Add to local state first
        if (!reactions.containsKey(postId)) {
          reactions[postId] = [];
        }
        reactions[postId].add({
          'id': tempId,
          'user_id': userId,
          'type': reactionType,
        });

        // Save updated reactions to local storage
        await saveReactionsToLocal(reactions);

        // Then try to add to server
        try {
          final jsonResponse = await _apiService.addReaction(userId, postId, reactionType);
          String serverId = jsonResponse['id'] ?? tempId;

          // Update the ID in our state
          if (reactions.containsKey(postId)) {
            for (var i = 0; i < reactions[postId].length; i++) {
              if (reactions[postId][i]['id'] == tempId) {
                reactions[postId][i]['id'] = serverId;
                break;
              }
            }
          }

          // Save the updated reactions with server ID
          await saveReactionsToLocal(reactions);
        } catch (e) {
          print('Server error adding reaction: $e');
          // Reaction remains in local state
        }
      }

      return reactions;
    } catch (e) {
      print('Error toggling reaction: $e');
      // Ensure reactions are saved even if there's an error
      await saveReactionsToLocal(reactions);
      return reactions;
    }
  }
}
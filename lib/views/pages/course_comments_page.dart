import 'package:flutter/material.dart';
import 'package:project_flutter/controllers/comment_controller.dart';
import 'package:project_flutter/models/comment.dart';

class CourseCommentsPage extends StatefulWidget {
  final int courseId;
  final int sectionId;
  final int postId;

  CourseCommentsPage({
    required this.courseId,
    required this.sectionId,
    required this.postId,
  });

  @override
  _CourseCommentsPageState createState() => _CourseCommentsPageState();
}

class _CourseCommentsPageState extends State<CourseCommentsPage> {
  late CommentController _controller;
  List<Comment> _comments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = CommentController(
      courseId: widget.courseId,
      sectionId: widget.sectionId,
      postId: widget.postId,
    );
    _loadComments();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<Comment> comments = await _controller.fetchComments();
      for (var comment in comments) {
        comment.isLiked = await _controller.checkIfLiked(comment.id);
        comment.likesCount = await _controller.getLikesCount(comment.id);
      }

      setState(() {
        _comments = comments;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddCommentDialog() {
    TextEditingController _commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Comment', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter your comment here...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_commentController.text.isNotEmpty) {
                  await _controller.addComment(_commentController.text);
                  Navigator.pop(context);
                  _loadComments();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _toggleLike(Comment comment) async {
    try {
      await _controller.toggleLike(comment);  
      setState(() {
        comment.isLiked = !comment.isLiked;
        comment.likesCount += comment.isLiked ? 1 : -1;
      });
    } catch (e) {
      print("Error toggling like: $e");
    }
  }

  void _showEditCommentDialog(Comment comment) {
    TextEditingController _commentController = TextEditingController(text: comment.body);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Comment', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Edit your comment here...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_commentController.text.isNotEmpty) {
                  await _controller.updateComment(comment.id, _commentController.text);
                  Navigator.pop(context);
                  _loadComments();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(Comment comment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Comment', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to delete this comment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () async {
                await _controller.deleteComment(comment.id);
                Navigator.pop(context);
                _loadComments();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        iconTheme: IconThemeData(color: Colors.white), 
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, 
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),  
        child: FloatingActionButton(
          onPressed: _showAddCommentDialog,
          child: Icon(Icons.add, color: Colors.white), 
          backgroundColor: Colors.indigo,
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 50, color: Colors.red),
                      SizedBox(height: 10),
                      Text(_errorMessage!, textAlign: TextAlign.center),
                    ],
                  ),
                )
              : _comments.isEmpty
                  ? Center(child: Text('No comments yet', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.indigo,
                                      child: Text(
                                        comment.author.isNotEmpty
                                            ? comment.author[0].toUpperCase()
                                            : 'A',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment.author,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          comment.datePosted,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  comment.body,
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        comment.isLiked
                                            ? Icons.thumb_up
                                            : Icons.thumb_up_off_alt,
                                        color: comment.isLiked ? Colors.indigo : Colors.grey,
                                      ),
                                      onPressed: () => _toggleLike(comment),
                                    ),
                                    Text('${comment.likesCount}'),
                                    SizedBox(width: 12),
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.indigo),
                                      onPressed: () => _showEditCommentDialog(comment),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _showDeleteConfirmationDialog(comment),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

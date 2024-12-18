import 'package:flutter/material.dart';
import 'package:project_flutter/models/post.dart'; // استيراد النموذج

class PostList extends StatelessWidget {
  final List<Post> posts;
  final Function(int postId, String updatedBody) onUpdate; // دالة التحديث
  final Function(int postId) onDelete; // دالة الحذف
  final Function(int postId) onTap; // دالة عند الضغط على المنشور

  PostList({
    required this.posts,
    required this.onUpdate,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        var post = posts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () {
              onTap(post.id);
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.body,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.grey[600], size: 16),
                        SizedBox(width: 8.0),
                        Text(
                          post.datePosted,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.grey[600], size: 16),
                        SizedBox(width: 8.0),
                        Text(
                          post.author,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    Divider(color: Colors.grey[300], thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _showUpdateDialog(context, post.id, post.body);
                          },
                          tooltip: 'Edit Post',
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            onDelete(post.id);
                          },
                          tooltip: 'Delete Post',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showUpdateDialog(BuildContext context, int postId, String currentBody) {
    TextEditingController _updateController =
        TextEditingController(text: currentBody);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Post'),
          content: TextField(
            controller: _updateController,
            maxLines: 5,
            decoration: InputDecoration(hintText: "Enter updated post content"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onUpdate(postId, _updateController.text);
                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}

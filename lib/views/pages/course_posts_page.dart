import 'package:flutter/material.dart';
import 'package:project_flutter/controllers/course_posts_controller.dart'; // استيراد الكنترولر
import 'package:project_flutter/views/pages/course_comments_page.dart';
import 'package:project_flutter/views/widgets/post_list.dart'; // استيراد widget لعرض المنشورات
import 'package:project_flutter/models/post.dart'; // استيراد النموذج

class CoursePostsPage extends StatefulWidget {
  final int courseId;
  final int sectionId;

  CoursePostsPage({required this.courseId, required this.sectionId});

  @override
  _CoursePostsPageState createState() => _CoursePostsPageState();
}

class _CoursePostsPageState extends State<CoursePostsPage> {
  List<Post> posts = [];
  String? _errorMessage;
  late CoursePostsController _controller;
  final TextEditingController _postController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = CoursePostsController();
    fetchPosts();
  }

  // دالة لتحميل المنشورات
  Future<void> fetchPosts() async {
    try {
      final fetchedPosts =
          await _controller.fetchPosts(widget.courseId, widget.sectionId);
      setState(() {
        posts = fetchedPosts;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  // دالة لإضافة منشور جديد
  Future<void> createPost() async {
    if (_postController.text.isNotEmpty) {
      try {
        final postId = await _controller.createPost(
            widget.courseId, widget.sectionId, _postController.text);
        setState(() {
          posts.add(Post(
            id: postId!,
            body: _postController.text,
            author: 'اسم المؤلف هنا',
            datePosted: DateTime.now().toString(),
          ));
        });
        _postController.clear();
        fetchPosts();
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Post content cannot be empty.';
      });
    }
  }

  // دالة لتحديث منشور موجود
  Future<void> updatePost(int postId, String updatedBody) async {
    try {
      await _controller.updatePost(
          widget.courseId, widget.sectionId, postId, updatedBody);
      fetchPosts();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  // دالة لحذف منشور
  Future<void> deletePost(int postId) async {
    try {
      await _controller.deletePost(widget.courseId, widget.sectionId, postId);
      setState(() {
        posts.removeWhere((post) => post.id == postId);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Course Posts',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _errorMessage != null
          ? Center(
              child: Text(_errorMessage!, style: TextStyle(color: Colors.red)))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _postController,
                    decoration: InputDecoration(
                      labelText: 'Add a post...',
                      border: OutlineInputBorder(),
                      errorText: _errorMessage,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: createPost,
                  child: Text('Post'),
                ),
                Expanded(
                  child: posts.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : PostList(
                          posts: posts,
                          onUpdate: updatePost,
                          onDelete: deletePost,
                          onTap: (postId) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourseCommentsPage(
                                  courseId: widget.courseId,
                                  sectionId: widget.sectionId,
                                  postId: postId,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

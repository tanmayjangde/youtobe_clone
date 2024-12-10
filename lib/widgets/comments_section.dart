import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentsSection extends StatelessWidget {
  final List<Map<String, dynamic>> comments;
  final bool isLoading;
  final VoidCallback onCommentsTap;
  final bool isExpanded;
  final VoidCallback onClose;

  const CommentsSection({
    super.key,
    required this.comments,
    required this.isLoading,
    required this.onCommentsTap,
    required this.isExpanded,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!isExpanded) {
      return _buildCollapsedComment();
    }
    return _buildExpandedComments();
  }

  Widget _buildCollapsedComment() {
    if (comments.isEmpty) return const SizedBox.shrink();

    return InkWell(
      onTap: onCommentsTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Comments ${comments.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white60),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundImage: NetworkImage(
                    comments.first['authorProfileImage'] ??
                        'https://placeholder.com/150',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comments.first['author'] ?? '',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comments.first['text'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedComments() {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          _buildHeader(),
          _buildTabs(),
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return _buildCommentItem(comment);
              },
            ),
          ),
          _buildAddComment(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white12),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Comments ${comments.length}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTab('Top', true),
            _buildTab('Newest', false),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String text, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white12 : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white60,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final DateTime publishedAt = DateTime.parse(comment['publishedAt']);
    final String timeAgo = timeago.format(publishedAt);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(
              comment['authorProfileImage'] ?? 'https://placeholder.com/150',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment['author'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment['text'] ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.thumb_up_outlined,
                        size: 16, color: Colors.white60),
                    const SizedBox(width: 4),
                    Text(
                      '${comment['likeCount'] ?? 0}',
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.thumb_down_outlined,
                        size: 16, color: Colors.white60),
                    const SizedBox(width: 16),
                    const Text(
                      'Reply',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddComment() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white12),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            child: Icon(Icons.person, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: const Text(
                'Add a comment...',
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

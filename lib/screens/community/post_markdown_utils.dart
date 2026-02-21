import 'package:markdown/markdown.dart' as md;

const String pendingImageSchemePrefix = 'pending://';

List<String> extractImageUrlsFromMarkdown(String content) {
  final imageUrls = <String>[];

  for (final node in _parseMarkdown(content)) {
    _visitNode(node, onImage: imageUrls.add);
  }

  return imageUrls;
}

Set<String> extractCommunityImageUrls(String content) {
  return extractImageUrlsFromMarkdown(
    content,
  ).where(_isCommunityStorageImageUrl).toSet();
}

int countMarkdownImages(String content) {
  return extractImageUrlsFromMarkdown(content).length;
}

String replacePendingImageTokens(
  String content,
  Map<String, String> replacements,
) {
  var replaced = content;
  for (final entry in replacements.entries) {
    replaced = replaced.replaceAll('(${entry.key})', '(${entry.value})');
    replaced = replaced.replaceAll(entry.key, entry.value);
  }
  return replaced;
}

String markdownToPlainTextSnippet(String content) {
  final buffer = StringBuffer();
  for (final node in _parseMarkdown(content)) {
    _collectText(node, buffer);
  }

  final normalized = buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.isEmpty) return '';

  const maxLength = 120;
  if (normalized.length <= maxLength) {
    return normalized;
  }

  return '${normalized.substring(0, maxLength - 3)}...';
}

List<md.Node> _parseMarkdown(String content) {
  final document = md.Document();
  final lines = content.replaceAll('\r\n', '\n').split('\n');
  return document.parseLines(lines);
}

void _visitNode(md.Node node, {required void Function(String url) onImage}) {
  if (node is md.Element) {
    if (node.tag == 'img') {
      final src = node.attributes['src'];
      if (src != null && src.isNotEmpty) {
        onImage(src);
      }
    }

    final children = node.children;
    if (children != null) {
      for (final child in children) {
        _visitNode(child, onImage: onImage);
      }
    }
  }
}

void _collectText(md.Node node, StringBuffer buffer) {
  if (node is md.Text) {
    buffer.write(node.text);
    return;
  }

  if (node is! md.Element) {
    return;
  }

  if (node.tag == 'img') {
    return;
  }

  final blockTags = <String>{
    'p',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'blockquote',
    'li',
    'pre',
  };

  final children = node.children;
  if (children != null) {
    for (final child in children) {
      _collectText(child, buffer);
    }
  }

  if (blockTags.contains(node.tag)) {
    buffer.write(' ');
  }
}

bool _isCommunityStorageImageUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.pathSegments.isEmpty) {
    return false;
  }

  final publicIndex = uri.pathSegments.indexOf('public');
  if (publicIndex == -1 || publicIndex + 1 >= uri.pathSegments.length) {
    return false;
  }

  return uri.pathSegments[publicIndex + 1] == 'community';
}

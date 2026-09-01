/// Builds browser download fallbacks for remotely hosted model files.
///
/// HuggingFace assets already send browser-friendly CORS headers, so web builds
/// should keep them on direct origins. The proxy path is reserved for hosts such
/// as GitHub Releases that do not reliably expose CORS headers to fetch().
List<String> modelDownloadCandidateUrls(
  String originalUrl, {
  Uri? baseUri,
  String productionOrigin = 'https://omni-trace-roan-three.vercel.app',
}) {
  final original = Uri.parse(originalUrl);
  final candidates = <String>[];

  if (original.host == 'huggingface.co') {
    candidates.add(originalUrl);
    candidates.add(original.replace(host: 'hf-mirror.com').toString());
    return _dedupe(candidates);
  }

  final encoded = Uri.encodeComponent(originalUrl);
  final sameOriginProxy = (baseUri ?? Uri.base)
      .resolve('/api/proxy?url=$encoded')
      .toString();
  final prodProxy = '$productionOrigin/api/proxy?url=$encoded';

  if (original.host == 'github.com' ||
      original.host == 'objects.githubusercontent.com') {
    candidates.add(sameOriginProxy);
    candidates.add(prodProxy);
    candidates.add(originalUrl);
  } else {
    candidates.add(sameOriginProxy);
    candidates.add(prodProxy);
    candidates.add(originalUrl);
  }
  return _dedupe(candidates);
}

List<String> _dedupe(List<String> urls) {
  final seen = <String>{};
  return [
    for (final url in urls)
      if (seen.add(url)) url,
  ];
}

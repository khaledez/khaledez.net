export default function handler(req, res) {
  const socketRemoteAddr = req.socket?.remoteAddress;
  const cloudfrontViewerAddr = req.headers["CloudFront-Viewer-Address"];
  const forwardedHead = req.headers["Forwarded"];
  res.status(200).json({
    remoteAddr: socketRemoteAddr,
    cloudfront: cloudfrontViewerAddr,
    forwarded: forwardedHead,
  });
}

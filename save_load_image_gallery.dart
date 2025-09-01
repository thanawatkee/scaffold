
final xfile = await picker.pickImage(source: ImageSource.camera);
if (xfile == null) {
  // fallback
  final fromGallery = await picker.pickImage(source: ImageSource.gallery);
  if (fromGallery == null) return;
  // ... บันทึกเหมือนเดิม
}

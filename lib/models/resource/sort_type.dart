class SortType {
  final SortEnum type;
  final String name;

  SortType({required this.type, required this.name});

  static SortType get defaultSortType =>
      SortType(type: SortEnum.nameAscending, name: 'Tên A → Z');

  static List<SortType> defaultSortTypeList() {
    return [
      defaultSortType,
      SortType(type: SortEnum.nameDescending, name: 'Tên Z → A'),
      SortType(type: SortEnum.sizeDescending, name: 'Tệp lớn nhất xếp trước'),
      SortType(type: SortEnum.sizeAscending, name: 'Tệp nhỏ nhất xếp trước'),
      SortType(
          type: SortEnum.creationTimeDescending,
          name: 'Ngày mới nhất xếp trước'),
      SortType(
          type: SortEnum.creationTimeAscending, name: 'Ngày cũ nhất xếp trước'),
    ];
  }
}

enum SortEnum {
  nameAscending, // Sắp xếp theo tên tăng dần
  nameDescending, // Sắp xếp theo tên giảm dần
  sizeAscending, // Sắp xếp theo kích thước file tăng dần
  sizeDescending, // Sắp xếp theo kích thước file giảm dần
  creationTimeAscending, // Sắp xếp theo ngày tạo tăng dần
  creationTimeDescending, // Sắp xếp theo ngày tạo giảm dần
}

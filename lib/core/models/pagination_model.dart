/// Pagination model for API responses
class PaginationModel<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasMore;

  const PaginationModel({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    this.hasMore = false,
  });

  factory PaginationModel.empty() {
    return const PaginationModel(
      items: [],
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
      hasMore: false,
    );
  }

  PaginationModel<T> copyWith({
    List<T>? items,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    bool? hasMore,
  }) {
    return PaginationModel<T>(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  /// Append new items (for load more)
  PaginationModel<T> appendItems(List<T> newItems) {
    return copyWith(
      items: [...items, ...newItems],
      currentPage: currentPage + 1,
      hasMore: newItems.isNotEmpty && currentPage < totalPages,
    );
  }
}


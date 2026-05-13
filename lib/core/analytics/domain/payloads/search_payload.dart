import 'package:equatable/equatable.dart';

import '../search_context.dart';

final class SearchPayload extends Equatable {
  final SearchContext context;
  final String searchTerm;
  final int? resultCount;

  const SearchPayload({
    required this.context,
    required this.searchTerm,
    this.resultCount,
  });

  @override
  List<Object?> get props => [context, searchTerm, resultCount];
}

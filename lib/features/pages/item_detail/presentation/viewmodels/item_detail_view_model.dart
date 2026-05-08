import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luotopia/features/pages/item_detail/domain/models/item_detail_args.dart';
import 'package:luotopia/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:luotopia/shared/domain/entities/agenda_item.dart';

class ItemDetailState {
  const ItemDetailState({
    required this.itemId,
    required this.item,
    this.isDeleting = false,
  });

  final String? itemId;
  final AgendaItem? item;
  final bool isDeleting;
}

final itemDetailViewModelProvider =
    Provider.family<ItemDetailState, ItemDetailArgs?>((ref, args) {
  final itemId = args?.itemId;
  final item = itemId == null ? null : ref.watch(agendaItemByIdProvider(itemId));
  return ItemDetailState(
    itemId: itemId,
    item: item,
  );
});


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:huajuan_agenda/features/item_detail/domain/models/item_detail_args.dart';
import 'package:huajuan_agenda/shared/data/repositories/in_memory_agenda_item_repository.dart';
import 'package:huajuan_agenda/shared/domain/entities/agenda_item.dart';

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


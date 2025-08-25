import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:copyright_clinic_flutter/core/constants/app_strings.dart';
import 'package:copyright_clinic_flutter/core/widgets/custom_scaffold.dart';
import 'package:copyright_clinic_flutter/core/widgets/translated_text.dart';
import '../bloc/item_bloc.dart';
import '../bloc/item_event.dart';
import '../bloc/item_state.dart';
import '../../../example_feature/domain/entities/item_entity.dart';

class ItemPage extends StatelessWidget {
  const ItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BlocProvider.of<ItemBloc>(context)..add(ItemRequested()),
      child: CustomScaffold(
        appBar: AppBar(title: TranslatedText(AppStrings.appName)),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.all(16.0), child: TranslatedText('', style: Theme.of(context).textTheme.titleLarge)),
            // Theme Preview Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  context.go('/theme-preview');
                },
                child: TranslatedText(AppStrings.viewThemePreview),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<ItemBloc, ItemState>(
                builder: (context, state) {
                  if (state is ItemLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ItemLoaded) {
                    return ListView.builder(
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final ItemEntity item = state.items[index];
                        return ListTile(title: Text(item.name), subtitle: Text(item.description));
                      },
                    );
                  } else if (state is ItemError) {
                    return Center(child: TranslatedText(AppStrings.errorMessage));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

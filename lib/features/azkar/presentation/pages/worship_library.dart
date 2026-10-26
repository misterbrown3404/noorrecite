import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/widgets/qari_app_bar.dart';
import 'package:flutter/material.dart';
import '../../data/worship_repository.dart';

/// Shared offline loading, search, empty and retry states for the collections.
class WorshipLibrary<T> extends StatefulWidget {
  const WorshipLibrary({
    super.key,
    required this.title,
    required this.subtitle,
    required this.load,
    required this.searchText,
    required this.itemBuilder,
    this.header,
    this.appBar,
    this.searchHint = 'Search',
  });
  final String title, subtitle, searchHint;
  final Future<List<T>> Function() load;
  final String Function(T) searchText;
  final Widget Function(BuildContext, T) itemBuilder;
  final Widget? header;
  final PreferredSizeWidget? appBar;
  @override
  State<WorshipLibrary<T>> createState() => _WorshipLibraryState<T>();
}

class _WorshipLibraryState<T> extends State<WorshipLibrary<T>> {
  late Future<List<T>> _future = widget.load();
  String _query = '';
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar:
        widget.appBar ??
        QariAppBar(title: widget.title, subtitle: 'QariVerse · Remembrance'),
    body: FutureBuilder<List<T>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Couldn’t load this collection.'),
                TextButton(
                  onPressed: () => setState(() => _future = widget.load()),
                  child: const Text('Try again'),
                ),
              ],
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snapshot.data!
            .where(
              (e) =>
                  normalizeWorshipSearch(widget.searchText(e)).contains(_query),
            )
            .toList();
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.subtitle.isNotEmpty)
                      Text(
                        widget.subtitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    if (widget.header != null) ...[
                      if (widget.subtitle.isNotEmpty)
                        const SizedBox(height: 18),
                      widget.header!,
                    ],
                    const SizedBox(height: 20),
                    TextField(
                      onChanged: (value) => setState(
                        () => _query = normalizeWorshipSearch(value),
                      ),
                      decoration: InputDecoration(
                        hintText: widget.searchHint,
                        prefixIcon: const Icon(LucideIcons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${items.length} of ${snapshot.data!.length}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ),
            if (items.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No matches. Try another name or phrase.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              sliver: SliverList.builder(
                itemCount: items.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: widget.itemBuilder(context, items[index]),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      },
    ),
  );
}

class WorshipTextCard extends StatelessWidget {
  const WorshipTextCard({
    super.key,
    required this.arabic,
    this.title,
    this.transliteration,
    this.meaning,
    this.reference,
    this.footer,
  });
  final String arabic;
  final String? title, transliteration, meaning, reference;
  final Widget? footer;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: .4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
          ],
          SelectableText(
            arabic,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 28,
              height: 1.9,
              color: colors.onSurface,
            ),
          ),
          if (transliteration != null) ...[
            const SizedBox(height: 16),
            SelectableText(
              transliteration!,
              style: const TextStyle(fontWeight: FontWeight.w600, height: 1.5),
            ),
          ],
          if (meaning != null) ...[
            const SizedBox(height: 10),
            SelectableText(
              meaning!,
              style: TextStyle(color: colors.onSurfaceVariant, height: 1.6),
            ),
          ],
          if (reference != null) ...[
            const SizedBox(height: 14),
            Text(
              reference!,
              style: TextStyle(color: colors.primary, fontSize: 12),
            ),
          ],
          if (footer != null) ...[const SizedBox(height: 18), footer!],
        ],
      ),
    );
  }
}

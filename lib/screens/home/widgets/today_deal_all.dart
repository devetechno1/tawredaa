import 'dart:collection';

import 'package:active_ecommerce_cms_demo_app/custom/home_banners/home_banners_list.dart';
import 'package:active_ecommerce_cms_demo_app/helpers/string_helper.dart';
import 'package:active_ecommerce_cms_demo_app/presenter/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app_config.dart';
import '../../../custom/style.dart';
import '../../../data_model/product_mini_response.dart';
import '../../../data_model/slider_response.dart';
import '../../../locale/custom_localization.dart';
import '../../product/product_details.dart';

class TodaysDealViewAllScreen extends StatelessWidget {
  const TodaysDealViewAllScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.select<HomeProvider, ({
      bool isInitial,
      UnmodifiableListView<Product> products,
      bool isBannerInitial,
      UnmodifiableListView<AIZSlider> bannerImages,
    })>(
      (p) => (
        isInitial: p.isTodayDealInitial,
        products: UnmodifiableListView(p.TodayDealList),
        isBannerInitial: p.isTodayDealBannerInitial,
        bannerImages: UnmodifiableListView(p.todayDealBannerImageList),
      ),
    );

    return Scaffold(
          appBar: AppBar(
        title: Text(
          'todays_deal_ucf'.tr(context: context),
          style: MyStyle.appBarStyle,
        ),
          ),
      body: RefreshIndicator(
        onRefresh: () => context.read<HomeProvider>().fetchTodayDealProducts(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: HomeBannersList(
                  isBannersInitial: data.isBannerInitial,
                  bannersImagesList: data.bannerImages,
                ),
              ),
            ),

            if (!data.isInitial && data.products.isEmpty)
              const SliverToBoxAdapter(child: emptyWidget),

            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingLarge,
                vertical: AppDimensions.paddingLarge,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = data.products[index];

                    return GestureDetector(
                      onTap: product.slug == null
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetails(slug: product.slug!),
                                ),
                              );
                            },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusSmall),
                              child: Image.network(
                                product.thumbnail_image ?? '',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.name ?? '',
                            maxLines: 2,
                            textDirection: (product.name ?? '').direction,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.main_price ?? '',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: data.products.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

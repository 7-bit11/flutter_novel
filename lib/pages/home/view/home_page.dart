import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_flutter_bit/base/base_provider.dart';
import 'package:novel_flutter_bit/base/base_state.dart';
import 'package:novel_flutter_bit/pages/home/view_model/view_model.dart';
import 'package:novel_flutter_bit/style/theme.dart';
import 'package:novel_flutter_bit/tools/padding_extension.dart';
import 'package:novel_flutter_bit/tools/size_extension.dart';
import 'package:novel_flutter_bit/widget/barber_pole_progress_bar.dart';
import 'package:pull_to_refresh_notification/pull_to_refresh_notification.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeViewModel _viewModel = HomeViewModel();

  double progress = .5;
  @override
  void initState() {
    super.initState();
    _viewModel.getData();
  }

  @override
  Widget build(BuildContext context) {
    final MyColorsTheme myColors =
        Theme.of(context).extension<MyColorsTheme>()!;
    return Scaffold(
      appBar: AppBar(title: const Text('每日推荐')),
      body: ProviderConsumer<HomeViewModel>(
        viewModel: _viewModel,
        builder: (BuildContext context, HomeViewModel value, Widget? child) {
          if (value.homeState.netState == NetState.loadingState) {
            return _buildLoading();
          }
          return _buildSuccess(myColors: myColors, value: value);
        },
      ),
    );
  }

  /// 成功状态构建
  _buildSuccess(
      {required MyColorsTheme myColors, required HomeViewModel value}) {
    return DefaultTextStyle(
      style: TextStyle(color: myColors.textColorHomePage),
      child: PullToRefreshNotification(
          onRefresh: value.onRefresh,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                  sliver: const SliverToBoxAdapter(
                      child: Text('我的阅读', style: TextStyle(fontSize: 20))),
                  padding: 10.padding),
              SliverToBoxAdapter(
                child: _buildReadList(value,
                    progress: progress, myColors: myColors),
              ),
              SliverPadding(
                  sliver: const SliverToBoxAdapter(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('全网最热', style: TextStyle(fontSize: 18)),
                      Icon(Icons.chevron_right)
                    ],
                  )),
                  padding: 10.padding),
            ],
          )),
    );
  }

  /// 加载中
  _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  /// 阅读列表
  _buildReadList(HomeViewModel value,
      {required double progress,
      required MyColorsTheme myColors,
      double height = 280,
      double widthItem = 160}) {
    return SizedBox(
      height: height,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: value.homeState.novelHot?.data?.length,
          itemBuilder: (context, index) {
            return _buildReadItem(
                width: widthItem,
                url: value.homeState.novelHot?.data?[index].img ?? "",
                bookName: value.homeState.novelHot?.data?[index].name ?? "",
                progress: progress.clamp(0, 1),
                myColors: myColors);
          }),
    );
  }

  /// 阅读列表item
  _buildReadItem(
      {required String url,
      required String bookName,
      required double progress,
      required double width,
      required MyColorsTheme myColors}) {
    return Container(
      margin: 5.padding,
      constraints: BoxConstraints(maxWidth: width, minWidth: width),
      decoration: BoxDecoration(
          color: myColors.containerColor,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(.2),
                blurRadius: 8.0,
                spreadRadius: 0.5)
          ]),
      child: DefaultTextStyle(
        style: TextStyle(color: myColors.textColorHomePage),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: ExtendedImage.network(
                  url,
                  cache: true,
                  width: width,
                  loadStateChanged: (state) {
                    switch (state.extendedImageLoadState) {
                      case LoadState.loading:
                        return const Center(child: CircularProgressIndicator());
                      case LoadState.completed:
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: ExtendedRawImage(
                              image: state.extendedImageInfo?.image,
                              fit: BoxFit.cover),
                        );
                      case LoadState.failed:
                        return LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return const Center(child: Text("加载失败"));
                        });
                    }
                  },
                ),
              ),
              1.verticalSpace,
              Padding(
                padding: 10.horizontal,
                child: Text(bookName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15)),
              ),
              1.verticalSpace,
              Padding(
                padding: 5.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                        child: BarberPoleProgressBar(
                            progress: progress,
                            animationEnabled: true,
                            color: myColors.brandColor,
                            notArriveProgressAnimation: false)),
                    5.horizontalSpace,
                    SizedBox(
                        width: 40,
                        child: Text('${(progress * 100).toStringAsFixed(0)}%'))
                  ],
                ),
              ),
              3.verticalSpace
            ]),
      ),
    );
  }
}

//
//  BannerView.swift
//  bannerDemo
//
//  Created by xiangyu on 2017/7/6.
//  Copyright © 2017年 xiangyu. All rights reserved.
//

import UIKit

class BannerView: UIView {
  fileprivate var collectionView: UICollectionView!
  fileprivate var pageControl: UIPageControl?
  fileprivate var timer: Timer?
  fileprivate var timerElapsed = NSDate()
  var timeInterval: TimeInterval = 4
  fileprivate var currentPage = 1
  fileprivate var cycleEnabled = true 
  var automaticScroll = true {
    didSet {
      timer?.fireDate = automaticScroll ? Date() : Date.distantFuture
    }
  }
  
  fileprivate var circleDataSource: [UIImage]?
  var dataSource = [UIImage]() {
    didSet {
      circleDataSource = dataSource
      pageControl?.numberOfPages = dataSource.count
      guard cycleEnabled && dataSource.count > 1 else {
        collectionView.reloadData()
        return
      }
      circleDataSource?.insert(dataSource.last!, at: 0)
      circleDataSource?.append(dataSource.first!)
      collectionView.reloadData()
      
      let indexPath = NSIndexPath(item: 1, section: 0)
      collectionView.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: true)
      
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupCollectionView()
    setupPageControl()
    setupTimer()
  }
  
  override func awakeFromNib() {
  }
  
  private func setupCollectionView() {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.itemSize = self.bounds.size
    layout.minimumLineSpacing = 0
    collectionView = UICollectionView(frame: self.bounds , collectionViewLayout: layout)
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.backgroundColor = self.backgroundColor
    collectionView.showsVerticalScrollIndicator = false
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.scrollsToTop = false
    collectionView.isPagingEnabled = true
    collectionView.register(UINib(nibName:"BannerViewItem",bundle:nil ), forCellWithReuseIdentifier: "BannerViewItem")
    addSubview(collectionView)
  }
  
  private func setupPageControl() {
    pageControl = UIPageControl(frame: CGRect(x: 0, y: self.bounds.height - 20, width: self.bounds.width, height: 20))
    addSubview(pageControl!)
  }
  
  private func setupTimer() {
    guard automaticScroll else { return }
    timer?.invalidate()
    timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(nextPage), userInfo: nil, repeats: true)
    RunLoop.current.add(timer!, forMode: .commonModes)
    timer?.fireDate = Date()
  }
  
  
  // MARK: - 计时器事件
  @objc fileprivate func nextPage() {
    timerElapsed = NSDate()
    if currentPage == (circleDataSource?.count)!  {
      collectionScrollToIndex(1, animated: false)
    } else {
      self.collectionScrollToIndex(currentPage, animated: true)
      if currentPage == (circleDataSource?.count)! { // 在timer运转的情况下，使最后一张图片过渡更平滑
        let when = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: when, execute: {
          self.collectionScrollToIndex(1, animated: false)
        })
      }
    }
  }
  fileprivate func collectionScrollToIndex(_ index: Int, animated: Bool) {
    currentPage = index
    let indexPath = NSIndexPath(item: index, section: 0)
    collectionView.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: animated)
    pageControl?.currentPage = currentPage - 1
    currentPage += 1
  }
}

extension BannerView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return circleDataSource?.count ?? 0
  }
}

extension BannerView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerViewItem", for: indexPath) as! BannerViewItem
    cell.imageView.image = circleDataSource?[indexPath.item]
    return cell
  }
}

extension BannerView: UIScrollViewDelegate {
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    guard automaticScroll else { return }
    timer?.fireDate = Date.distantFuture
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard automaticScroll else { return }
    let elapsedInterval = timeInterval - (Date().timeIntervalSince(timerElapsed as Date)).truncatingRemainder(dividingBy: timeInterval)
    timer?.fireDate = Date(timeInterval: elapsedInterval, since: Date())
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let offset = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
    guard cycleEnabled else {
      pageControl?.currentPage = offset
      return
    }
    if offset == 0 {
      DispatchQueue.main.async {
        self.collectionScrollToIndex((self.circleDataSource?.count)! - 2, animated: false)
      }
    } else if offset == ((self.circleDataSource?.count)! - 1) {
      DispatchQueue.main.async {
        self.collectionScrollToIndex(1, animated: false)
      }
    } else {
      self.collectionScrollToIndex(offset, animated: true)

    }
    
  }
}

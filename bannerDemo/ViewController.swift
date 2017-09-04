//
//  ViewController.swift
//  bannerDemo
//
//  Created by xiangyu on 2017/7/6.
//  Copyright © 2017年 xiangyu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var banner: BannerView!
  override func viewDidLoad() {
    super.viewDidLoad()
    banner.dataSource = [#imageLiteral(resourceName: "image1"), #imageLiteral(resourceName: "image2"),#imageLiteral(resourceName: "image3"), #imageLiteral(resourceName: "image4")]
    let ban = BannerView(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 40)))
    ban.dataSource = [#imageLiteral(resourceName: "image1"), #imageLiteral(resourceName: "image2"),#imageLiteral(resourceName: "image3"), #imageLiteral(resourceName: "image4")]
    view.addSubview(ban)
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}


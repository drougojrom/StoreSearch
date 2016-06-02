//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by Roman Ustiantcev on 01/06/16.
//  Copyright © 2016 Roman Ustiantcev. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControll: UIPageControl!
    
    var searchResults = [SearchResult]()
    
    private var firstTime = true
    
    
    private func tileButtons(searchResults: [SearchResult]) {
        var columnPerPage = 5
        var rowsPerPage = 3
        var itemWidth: CGFloat = 96
        var itemHeight: CGFloat = 88
        var marginX: CGFloat = 0
        var marginY: CGFloat = 20
        
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth)/2
        let paddingVert = (itemHeight - buttonHeight)/2
        
        var row = 0
        var column = 0
        var x = marginX
        for searchResult in searchResults {
            // 1 - create a UIButton object
            let button = UIButton(type: .System)
            button.backgroundColor = UIColor.whiteColor()
            button.setTitle("\(index)", forState: .Normal)
            
            // 2 - set the frame
            button.frame = CGRect(x: x + paddingHorz,
                                  y: marginY + CGFloat(row)*itemHeight + paddingVert,
                                  width: buttonWidth,
                                  height: buttonHeight)
            // 3 - add button as subview
            scrollView.addSubview(button)
            // 4 - position buttons
            row += 1
            if row == rowsPerPage {
                row = 0
                x += itemWidth
                column += 1
                
                if column == columnPerPage {
                    column = 0
                    x += marginX * 2
                }
            }
        }
        
        let scrollViewWidth = scrollView.bounds.size.width
        
        switch scrollViewWidth {
        case 568:
            columnPerPage = 6
            itemWidth = 96
            marginX = 2
        case 667:
            columnPerPage = 7
            itemWidth = 96
            itemHeight = 98
            marginX = 1
            marginY = 29
        case 736:
            columnPerPage = 8
            rowsPerPage = 4
            itemWidth = 92
        default:
            break
        }
        
        let buttonPerPage = columnPerPage * rowsPerPage
        let numPages = 1 + (searchResults.count - 1) / buttonPerPage
        scrollView.contentSize = CGSize(width: CGFloat(numPages)*scrollViewWidth,
                                        height: scrollView.bounds.size.height)
        print("Number of pages is \(numPages)")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        
        pageControll.removeConstraints(pageControll.constraints)
        pageControll.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        scrollView.contentSize = CGSize(width: 1000, height: 1000)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        pageControll.frame = CGRect(
            x: 0,
            y: view.frame.size.height - pageControll.frame.size.height,
            width: view.frame.size.width,
            height: pageControll.frame.size.height)
        
        if firstTime {
            firstTime = false
            tileButtons(searchResults)
        }
    }
    
    deinit {
        print("Deinit \(self)")
    }

}

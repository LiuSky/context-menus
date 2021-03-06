//
//  VCPreviewTableViewController.swift
//  ContextMenu
//
//  Created by Kyle Bashour on 8/20/19.
//  Copyright © 2019 Kyle Bashour. All rights reserved.
//

import UIKit

/*

 This view controller displays a list of icons with their names, and uses a view controller for the menu preview.
 When the preview is tapped, it pushes that view controller.

 */

/// A view controller used for previewing and when an item is selected
private class PhotoPreviewViewController: UIViewController {
    private let imageName: String
    private let imageView = UIImageView()

    init(imageName: String) {
        self.imageName = imageName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = imageName.capitalized
        let image = UIImage(named: imageName)!

        imageView.image = image
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.frame = view.bounds
        view.addSubview(imageView)

        // The preview will size to the preferredContentSize, which can be useful
        // for displaying a preview with the dimension of an image, for example.
        // Unlike peek and pop, it doesn't automatically scale down for you.

        let width: CGFloat
        let height: CGFloat

        if image.size.width > image.size.height {
            width = view.frame.width
            height = image.size.height * (width / image.size.width)
        } else {
            height = view.frame.height
            width = image.size.width * (height / image.size.height)
        }

        preferredContentSize = CGSize(width: width, height: height)
    }
}

/// Displays the name of the image
private class PhotoDetailViewController: UIViewController {
    private let imageName: String
    private let imageNameLabel = UILabel()

    init(imageName: String) {
        self.imageName = imageName
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = imageName.capitalized
        view.backgroundColor = .secondarySystemBackground

        imageNameLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        imageNameLabel.textColor = .label
        imageNameLabel.textAlignment = .center
        imageNameLabel.text = imageName.capitalized
        imageNameLabel.sizeToFit()
        view.addSubview(imageNameLabel)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageNameLabel.center = view.center
    }
}

/// A collection view cell that displays an image
private class PhotoCell: UICollectionViewCell {
    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.frame = contentView.bounds
        contentView.addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func display(imageNamed imageName: String) {
        imageView.image = UIImage(named: imageName)
    }
}

class VCPreviewCollectionViewController: UICollectionViewController, ContextMenuDemo {

    // MARK: ContextMenuDemo

    static var title: String { return "UIViewController (Collection View)" }

    // MARK: CollectionViewController

    private let identifier = "cell"

    init() {
        super.init(collectionViewLayout: Self.makeCollectionViewLayout())
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = Self.title

        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: identifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private static func makeCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / 3), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1.0 / 3))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
        group.interItemSpacing = .fixed(1)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 1

        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - UICollectionViewDelegate

    /*

     The `previewProvider` argument needs a function
     that returns a view controller. Here we configure a
     preview with the image at the items index.

     When creating our configuration, we'll specify an
     identifier so that we can tell which item is being
     previewed in `willPerformPreviewActionForMenuWith`.
     Then we can push a different detail view for that item.

     */

    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        // We have to create an NSString since the identifier must conform to NSCopying
        let identifier = NSString(string: Fixtures.images[indexPath.row])

        // Create our configuration with an indentifier
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: {
            return PhotoPreviewViewController(imageName: Fixtures.images[indexPath.row])
        }, actionProvider: { suggestedActions in
            return self.makeDefaultDemoMenu()
        })
    }

    override func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion {

            // We should have our image name set as the identifier of the configuration
            if let identifier = configuration.identifier as? String {
                let viewController = PhotoDetailViewController(imageName: identifier)
                self.show(viewController, sender: self)
            }
        }
    }

    // MARK: - UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Fixtures.images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! PhotoCell
        cell.display(imageNamed: Fixtures.images[indexPath.row])
        return cell
    }
}

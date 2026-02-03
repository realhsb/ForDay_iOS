//
//  CoverImageOptionSheet.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

import UIKit

class CoverImageOptionSheet {

    static func present(
        on viewController: UIViewController,
        onGallerySelected: @escaping () -> Void,
        onActivitySelected: @escaping () -> Void
    ) {
        let alert = UIAlertController(
            title: "대표사진 선택",
            message: "대표사진을 어디에서 선택하시겠어요?",
            preferredStyle: .actionSheet
        )

        // 앨범에서 선택
        let galleryAction = UIAlertAction(title: "앨범에서 선택", style: .default) { _ in
            onGallerySelected()
        }

        // 활동에서 선택
        let activityAction = UIAlertAction(title: "활동에서 선택", style: .default) { _ in
            onActivitySelected()
        }

        // 취소
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)

        alert.addAction(galleryAction)
        alert.addAction(activityAction)
        alert.addAction(cancelAction)

        // iPad support
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = CGRect(
                x: viewController.view.bounds.midX,
                y: viewController.view.bounds.midY,
                width: 0,
                height: 0
            )
            popoverController.permittedArrowDirections = []
        }

        viewController.present(alert, animated: true)
    }
}

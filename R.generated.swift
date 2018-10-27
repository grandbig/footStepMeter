//
// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift
//

import Foundation
import Rswift
import UIKit

/// This `R` struct is generated and contains references to static resources.
struct R: Rswift.Validatable {
  fileprivate static let applicationLocale = hostingBundle.preferredLocalizations.first.flatMap(Locale.init) ?? Locale.current
  fileprivate static let hostingBundle = Bundle(for: R.Class.self)
  
  static func validate() throws {
    try intern.validate()
  }
  
  /// This `R.image` struct is generated, and contains static references to 10 images.
  struct image {
    /// Image `AnimalFootprint`.
    static let animalFootprint = Rswift.ImageResource(bundle: R.hostingBundle, name: "AnimalFootprint")
    /// Image `Cancel`.
    static let cancel = Rswift.ImageResource(bundle: R.hostingBundle, name: "Cancel")
    /// Image `ChangeFootprint`.
    static let changeFootprint = Rswift.ImageResource(bundle: R.hostingBundle, name: "ChangeFootprint")
    /// Image `Footprint`.
    static let footprint = Rswift.ImageResource(bundle: R.hostingBundle, name: "Footprint")
    /// Image `Location`.
    static let location = Rswift.ImageResource(bundle: R.hostingBundle, name: "Location")
    /// Image `Mail`.
    static let mail = Rswift.ImageResource(bundle: R.hostingBundle, name: "Mail")
    /// Image `Settings`.
    static let settings = Rswift.ImageResource(bundle: R.hostingBundle, name: "Settings")
    /// Image `Start`.
    static let start = Rswift.ImageResource(bundle: R.hostingBundle, name: "Start")
    /// Image `Stop`.
    static let stop = Rswift.ImageResource(bundle: R.hostingBundle, name: "Stop")
    /// Image `View`.
    static let view = Rswift.ImageResource(bundle: R.hostingBundle, name: "View")
    
    /// `UIImage(named: "AnimalFootprint", bundle: ..., traitCollection: ...)`
    static func animalFootprint(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.animalFootprint, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "Cancel", bundle: ..., traitCollection: ...)`
    static func cancel(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.cancel, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "ChangeFootprint", bundle: ..., traitCollection: ...)`
    static func changeFootprint(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.changeFootprint, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "Footprint", bundle: ..., traitCollection: ...)`
    static func footprint(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.footprint, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "Location", bundle: ..., traitCollection: ...)`
    static func location(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.location, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "Mail", bundle: ..., traitCollection: ...)`
    static func mail(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.mail, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "Settings", bundle: ..., traitCollection: ...)`
    static func settings(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.settings, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "Start", bundle: ..., traitCollection: ...)`
    static func start(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.start, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "Stop", bundle: ..., traitCollection: ...)`
    static func stop(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.stop, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "View", bundle: ..., traitCollection: ...)`
    static func view(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.view, compatibleWith: traitCollection)
    }
    
    fileprivate init() {}
  }
  
  /// This `R.nib` struct is generated, and contains static references to 2 nibs.
  struct nib {
    /// Nib `MapViewController`.
    static let mapViewController = _R.nib._MapViewController()
    /// Nib `PickerView`.
    static let pickerView = _R.nib._PickerView()
    
    /// `UINib(name: "MapViewController", in: bundle)`
    @available(*, deprecated, message: "Use UINib(resource: R.nib.mapViewController) instead")
    static func mapViewController(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.mapViewController)
    }
    
    /// `UINib(name: "PickerView", in: bundle)`
    @available(*, deprecated, message: "Use UINib(resource: R.nib.pickerView) instead")
    static func pickerView(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.pickerView)
    }
    
    static func mapViewController(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> UIKit.UIView? {
      return R.nib.mapViewController.instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
    }
    
    static func pickerView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> UIKit.UIView? {
      return R.nib.pickerView.instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
    }
    
    fileprivate init() {}
  }
  
  /// This `R.reuseIdentifier` struct is generated, and contains static references to 3 reuse identifiers.
  struct reuseIdentifier {
    /// Reuse identifier `FootprintHistoryCell`.
    static let footprintHistoryCell: Rswift.ReuseIdentifier<UIKit.UITableViewCell> = Rswift.ReuseIdentifier(identifier: "FootprintHistoryCell")
    /// Reuse identifier `FootprintsCell`.
    static let footprintsCell: Rswift.ReuseIdentifier<UIKit.UITableViewCell> = Rswift.ReuseIdentifier(identifier: "FootprintsCell")
    /// Reuse identifier `SettingsCell`.
    static let settingsCell: Rswift.ReuseIdentifier<UIKit.UITableViewCell> = Rswift.ReuseIdentifier(identifier: "SettingsCell")
    
    fileprivate init() {}
  }
  
  /// This `R.segue` struct is generated, and contains static references to 3 view controllers.
  struct segue {
    /// This struct is generated for `FootprintsViewController`, and contains static references to 1 segues.
    struct footprintsViewController {
      /// Segue identifier `historyViewSegue`.
      static let historyViewSegue: Rswift.StoryboardSegueIdentifier<UIKit.UIStoryboardSegue, FootprintsViewController, HistoryViewController> = Rswift.StoryboardSegueIdentifier(identifier: "historyViewSegue")
      
      /// Optionally returns a typed version of segue `historyViewSegue`.
      /// Returns nil if either the segue identifier, the source, destination, or segue types don't match.
      /// For use inside `prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)`.
      static func historyViewSegue(segue: UIKit.UIStoryboardSegue) -> Rswift.TypedStoryboardSegueInfo<UIKit.UIStoryboardSegue, FootprintsViewController, HistoryViewController>? {
        return Rswift.TypedStoryboardSegueInfo(segueIdentifier: R.segue.footprintsViewController.historyViewSegue, segue: segue)
      }
      
      fileprivate init() {}
    }
    
    /// This struct is generated for `SettingViewController`, and contains static references to 2 segues.
    struct settingViewController {
      /// Segue identifier `aboutAppSegue`.
      static let aboutAppSegue: Rswift.StoryboardSegueIdentifier<UIKit.UIStoryboardSegue, SettingViewController, AboutAppViewController> = Rswift.StoryboardSegueIdentifier(identifier: "aboutAppSegue")
      /// Segue identifier `footprintHistorySegue`.
      static let footprintHistorySegue: Rswift.StoryboardSegueIdentifier<UIKit.UIStoryboardSegue, SettingViewController, FootprintsViewController> = Rswift.StoryboardSegueIdentifier(identifier: "footprintHistorySegue")
      
      /// Optionally returns a typed version of segue `aboutAppSegue`.
      /// Returns nil if either the segue identifier, the source, destination, or segue types don't match.
      /// For use inside `prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)`.
      static func aboutAppSegue(segue: UIKit.UIStoryboardSegue) -> Rswift.TypedStoryboardSegueInfo<UIKit.UIStoryboardSegue, SettingViewController, AboutAppViewController>? {
        return Rswift.TypedStoryboardSegueInfo(segueIdentifier: R.segue.settingViewController.aboutAppSegue, segue: segue)
      }
      
      /// Optionally returns a typed version of segue `footprintHistorySegue`.
      /// Returns nil if either the segue identifier, the source, destination, or segue types don't match.
      /// For use inside `prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)`.
      static func footprintHistorySegue(segue: UIKit.UIStoryboardSegue) -> Rswift.TypedStoryboardSegueInfo<UIKit.UIStoryboardSegue, SettingViewController, FootprintsViewController>? {
        return Rswift.TypedStoryboardSegueInfo(segueIdentifier: R.segue.settingViewController.footprintHistorySegue, segue: segue)
      }
      
      fileprivate init() {}
    }
    
    /// This struct is generated for `ViewController`, and contains static references to 1 segues.
    struct viewController {
      /// Segue identifier `settingsSegue`.
      static let settingsSegue: Rswift.StoryboardSegueIdentifier<UIKit.UIStoryboardSegue, ViewController, SettingViewController> = Rswift.StoryboardSegueIdentifier(identifier: "settingsSegue")
      
      /// Optionally returns a typed version of segue `settingsSegue`.
      /// Returns nil if either the segue identifier, the source, destination, or segue types don't match.
      /// For use inside `prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)`.
      static func settingsSegue(segue: UIKit.UIStoryboardSegue) -> Rswift.TypedStoryboardSegueInfo<UIKit.UIStoryboardSegue, ViewController, SettingViewController>? {
        return Rswift.TypedStoryboardSegueInfo(segueIdentifier: R.segue.viewController.settingsSegue, segue: segue)
      }
      
      fileprivate init() {}
    }
    
    fileprivate init() {}
  }
  
  /// This `R.string` struct is generated, and contains static references to 5 localization tables.
  struct string {
    /// This `R.string.common` struct is generated, and contains static references to 3 localization keys.
    struct common {
      /// Value: OK
      static let ok = Rswift.StringResource(key: "ok", tableName: "Common", bundle: R.hostingBundle, locales: [], comment: nil)
      /// Value: キャンセル
      static let cancel = Rswift.StringResource(key: "cancel", tableName: "Common", bundle: R.hostingBundle, locales: [], comment: nil)
      /// Value: 確認
      static let confirmTitle = Rswift.StringResource(key: "confirmTitle", tableName: "Common", bundle: R.hostingBundle, locales: [], comment: nil)
      
      /// Value: OK
      static func ok(_: Void = ()) -> String {
        return NSLocalizedString("ok", tableName: "Common", bundle: R.hostingBundle, comment: "")
      }
      
      /// Value: キャンセル
      static func cancel(_: Void = ()) -> String {
        return NSLocalizedString("cancel", tableName: "Common", bundle: R.hostingBundle, comment: "")
      }
      
      /// Value: 確認
      static func confirmTitle(_: Void = ()) -> String {
        return NSLocalizedString("confirmTitle", tableName: "Common", bundle: R.hostingBundle, comment: "")
      }
      
      fileprivate init() {}
    }
    
    /// This `R.string.infoPlist` struct is generated, and contains static references to 2 localization keys.
    struct infoPlist {
      /// Base translation: FootStepMeter
      /// 
      /// Locales: Base, ja
      static let cfBundleDisplayName = Rswift.StringResource(key: "CFBundleDisplayName", tableName: "InfoPlist", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: Use your location to save it and display it on the Map
      /// 
      /// Locales: Base, ja
      static let nsLocationAlwaysUsageDescription = Rswift.StringResource(key: "NSLocationAlwaysUsageDescription", tableName: "InfoPlist", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      
      /// Base translation: FootStepMeter
      /// 
      /// Locales: Base, ja
      static func cfBundleDisplayName(_: Void = ()) -> String {
        return NSLocalizedString("CFBundleDisplayName", tableName: "InfoPlist", bundle: R.hostingBundle, value: "FootStepMeter", comment: "")
      }
      
      /// Base translation: Use your location to save it and display it on the Map
      /// 
      /// Locales: Base, ja
      static func nsLocationAlwaysUsageDescription(_: Void = ()) -> String {
        return NSLocalizedString("NSLocationAlwaysUsageDescription", tableName: "InfoPlist", bundle: R.hostingBundle, value: "Use your location to save it and display it on the Map", comment: "")
      }
      
      fileprivate init() {}
    }
    
    /// This `R.string.localizable` struct is generated, and contains static references to 24 localization keys.
    struct localizable {
      /// Base translation: 100m Accuracy
      /// 
      /// Locales: Base, ja
      static let hundredMeters = Rswift.StringResource(key: "hundredMeters", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: 10m Accuracy
      /// 
      /// Locales: Base, ja
      static let nearestTenMeters = Rswift.StringResource(key: "nearestTenMeters", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: 1km Accuracy
      /// 
      /// Locales: Base, ja
      static let kilometer = Rswift.StringResource(key: "kilometer", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: 3km Accuracy
      /// 
      /// Locales: Base, ja
      static let threeKilometers = Rswift.StringResource(key: "threeKilometers", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: About App
      /// 
      /// Locales: Base, ja
      static let aboutAppRowTitle = Rswift.StringResource(key: "aboutAppRowTitle", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: Alert
      /// 
      /// Locales: Base, ja
      static let alertTitle = Rswift.StringResource(key: "alertTitle", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: Animal
      /// 
      /// Locales: Base, ja
      static let selectableAnimalIconRowTitle = Rswift.StringResource(key: "selectableAnimalIconRowTitle", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: Cancel
      /// 
      /// Locales: Base, ja
      static let cancelButton = Rswift.StringResource(key: "cancelButton", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: Confirm
      /// 
      /// Locales: Base, ja
      static let confirmTitle = Rswift.StringResource(key: "confirmTitle", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: Footprint Count:
      /// 
      /// Locales: Base, ja
      static let footprintCellDetailText = Rswift.StringResource(key: "footprintCellDetailText", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: Footprint History
      /// 
      /// Locales: Base, ja
      static let footprintHistoryRowTitle = Rswift.StringResource(key: "footprintHistoryRowTitle", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: High Accuracy
      /// 
      /// Locales: Base, ja
      static let best = Rswift.StringResource(key: "best", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: Highest Accuracy
      /// 
      /// Locales: Base, ja
      static let bestForNavigation = Rswift.StringResource(key: "bestForNavigation", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: Human
      /// 
      /// Locales: Base, ja
      static let selectableHumanIconRowTitle = Rswift.StringResource(key: "selectableHumanIconRowTitle", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: Input the title
      /// 
      /// Locales: Base, ja
      static let confirmMessageToInputTitle = Rswift.StringResource(key: "confirmMessageToInputTitle", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: Licence
      /// 
      /// Locales: Base, ja
      static let licenceRowTitle = Rswift.StringResource(key: "licenceRowTitle", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: OK
      /// 
      /// Locales: Base, ja
      static let okButton = Rswift.StringResource(key: "okButton", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: Please input the text.
      /// 
      /// Locales: Base, ja
      static let alertMessageToInputTitle = Rswift.StringResource(key: "alertMessageToInputTitle", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: Please stop to measure your location.
      /// 
      /// Locales: Base, ja
      static let alertMessageToStopLocation = Rswift.StringResource(key: "alertMessageToStopLocation", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: Start to save your footprints
      /// 
      /// Locales: Base, ja
      static let alertMessageToSaveFootprint = Rswift.StringResource(key: "alertMessageToSaveFootprint", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: Stop to measure your location.
      /// 
      /// Locales: Base, ja
      static let confirmMessageToStopLocation = Rswift.StringResource(key: "confirmMessageToStopLocation", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: There are no data to delete.
      /// 
      /// Locales: Base, ja
      static let alertMessageNoData = Rswift.StringResource(key: "alertMessageNoData", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: You already save the same title data. You have to change your title.
      /// 
      /// Locales: Base, ja
      static let alertMessageNotToSaveTitle = Rswift.StringResource(key: "alertMessageNotToSaveTitle", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      /// Base translation: attached CSV file
      /// 
      /// Locales: Base, ja
      static let sendMailSubject = Rswift.StringResource(key: "sendMailSubject", tableName: "Localizable", bundle: R.hostingBundle, locales: ["Base", "ja"], comment: nil)
      
      /// Base translation: 100m Accuracy
      /// 
      /// Locales: Base, ja
      static func hundredMeters(_: Void = ()) -> String {
        return NSLocalizedString("hundredMeters", bundle: R.hostingBundle, value: "100m Accuracy", comment: "")
      }
      
      /// Base translation: 10m Accuracy
      /// 
      /// Locales: Base, ja
      static func nearestTenMeters(_: Void = ()) -> String {
        return NSLocalizedString("nearestTenMeters", bundle: R.hostingBundle, value: "10m Accuracy", comment: "")
      }
      
      /// Base translation: 1km Accuracy
      /// 
      /// Locales: Base, ja
      static func kilometer(_: Void = ()) -> String {
        return NSLocalizedString("kilometer", bundle: R.hostingBundle, value: "1km Accuracy", comment: "")
      }
      
      /// Base translation: 3km Accuracy
      /// 
      /// Locales: Base, ja
      static func threeKilometers(_: Void = ()) -> String {
        return NSLocalizedString("threeKilometers", bundle: R.hostingBundle, value: "3km Accuracy", comment: "")
      }
      
      /// Base translation: About App
      /// 
      /// Locales: Base, ja
      static func aboutAppRowTitle(_: Void = ()) -> String {
        return NSLocalizedString("aboutAppRowTitle", bundle: R.hostingBundle, value: "About App", comment: "")
      }
      
      /// Base translation: Alert
      /// 
      /// Locales: Base, ja
      static func alertTitle(_: Void = ()) -> String {
        return NSLocalizedString("alertTitle", bundle: R.hostingBundle, value: "Alert", comment: "")
      }
      
      /// Base translation: Animal
      /// 
      /// Locales: Base, ja
      static func selectableAnimalIconRowTitle(_: Void = ()) -> String {
        return NSLocalizedString("selectableAnimalIconRowTitle", bundle: R.hostingBundle, value: "Animal", comment: "")
      }
      
      /// Base translation: Cancel
      /// 
      /// Locales: Base, ja
      static func cancelButton(_: Void = ()) -> String {
        return NSLocalizedString("cancelButton", bundle: R.hostingBundle, value: "Cancel", comment: "")
      }
      
      /// Base translation: Confirm
      /// 
      /// Locales: Base, ja
      static func confirmTitle(_: Void = ()) -> String {
        return NSLocalizedString("confirmTitle", bundle: R.hostingBundle, value: "Confirm", comment: "")
      }
      
      /// Base translation: Footprint Count:
      /// 
      /// Locales: Base, ja
      static func footprintCellDetailText(_: Void = ()) -> String {
        return NSLocalizedString("footprintCellDetailText", bundle: R.hostingBundle, value: "Footprint Count:", comment: "")
      }
      
      /// Base translation: Footprint History
      /// 
      /// Locales: Base, ja
      static func footprintHistoryRowTitle(_: Void = ()) -> String {
        return NSLocalizedString("footprintHistoryRowTitle", bundle: R.hostingBundle, value: "Footprint History", comment: "")
      }
      
      /// Base translation: High Accuracy
      /// 
      /// Locales: Base, ja
      static func best(_: Void = ()) -> String {
        return NSLocalizedString("best", bundle: R.hostingBundle, value: "High Accuracy", comment: "")
      }
      
      /// Base translation: Highest Accuracy
      /// 
      /// Locales: Base, ja
      static func bestForNavigation(_: Void = ()) -> String {
        return NSLocalizedString("bestForNavigation", bundle: R.hostingBundle, value: "Highest Accuracy", comment: "")
      }
      
      /// Base translation: Human
      /// 
      /// Locales: Base, ja
      static func selectableHumanIconRowTitle(_: Void = ()) -> String {
        return NSLocalizedString("selectableHumanIconRowTitle", bundle: R.hostingBundle, value: "Human", comment: "")
      }
      
      /// Base translation: Input the title
      /// 
      /// Locales: Base, ja
      static func confirmMessageToInputTitle(_: Void = ()) -> String {
        return NSLocalizedString("confirmMessageToInputTitle", bundle: R.hostingBundle, value: "Input the title", comment: "")
      }
      
      /// Base translation: Licence
      /// 
      /// Locales: Base, ja
      static func licenceRowTitle(_: Void = ()) -> String {
        return NSLocalizedString("licenceRowTitle", bundle: R.hostingBundle, value: "Licence", comment: "")
      }
      
      /// Base translation: OK
      /// 
      /// Locales: Base, ja
      static func okButton(_: Void = ()) -> String {
        return NSLocalizedString("okButton", bundle: R.hostingBundle, value: "OK", comment: "")
      }
      
      /// Base translation: Please input the text.
      /// 
      /// Locales: Base, ja
      static func alertMessageToInputTitle(_: Void = ()) -> String {
        return NSLocalizedString("alertMessageToInputTitle", bundle: R.hostingBundle, value: "Please input the text.", comment: "")
      }
      
      /// Base translation: Please stop to measure your location.
      /// 
      /// Locales: Base, ja
      static func alertMessageToStopLocation(_: Void = ()) -> String {
        return NSLocalizedString("alertMessageToStopLocation", bundle: R.hostingBundle, value: "Please stop to measure your location.", comment: "")
      }
      
      /// Base translation: Start to save your footprints
      /// 
      /// Locales: Base, ja
      static func alertMessageToSaveFootprint(_: Void = ()) -> String {
        return NSLocalizedString("alertMessageToSaveFootprint", bundle: R.hostingBundle, value: "Start to save your footprints", comment: "")
      }
      
      /// Base translation: Stop to measure your location.
      /// 
      /// Locales: Base, ja
      static func confirmMessageToStopLocation(_: Void = ()) -> String {
        return NSLocalizedString("confirmMessageToStopLocation", bundle: R.hostingBundle, value: "Stop to measure your location.", comment: "")
      }
      
      /// Base translation: There are no data to delete.
      /// 
      /// Locales: Base, ja
      static func alertMessageNoData(_: Void = ()) -> String {
        return NSLocalizedString("alertMessageNoData", bundle: R.hostingBundle, value: "There are no data to delete.", comment: "")
      }
      
      /// Base translation: You already save the same title data. You have to change your title.
      /// 
      /// Locales: Base, ja
      static func alertMessageNotToSaveTitle(_: Void = ()) -> String {
        return NSLocalizedString("alertMessageNotToSaveTitle", bundle: R.hostingBundle, value: "You already save the same title data. You have to change your title.", comment: "")
      }
      
      /// Base translation: attached CSV file
      /// 
      /// Locales: Base, ja
      static func sendMailSubject(_: Void = ()) -> String {
        return NSLocalizedString("sendMailSubject", bundle: R.hostingBundle, value: "attached CSV file", comment: "")
      }
      
      fileprivate init() {}
    }
    
    /// This `R.string.mapView` struct is generated, and contains static references to 4 localization keys.
    struct mapView {
      /// Value: タイトルを入力してください。
      static let inputTitleMessage = Rswift.StringResource(key: "inputTitleMessage", tableName: "MapView", bundle: R.hostingBundle, locales: [], comment: nil)
      /// Value: 位置情報の計測を停止しますか？
      static let stopUpdatingLocationMessage = Rswift.StringResource(key: "stopUpdatingLocationMessage", tableName: "MapView", bundle: R.hostingBundle, locales: [], comment: nil)
      /// Value: 位置情報の計測を停止する必要があります。
      static let needToStopUpdatingLocationErrorMessage = Rswift.StringResource(key: "needToStopUpdatingLocationErrorMessage", tableName: "MapView", bundle: R.hostingBundle, locales: [], comment: nil)
      /// Value: 既に同名のタイトルがあります。タイトルを変更してください。
      static let alreadySameTitleErrorMessage = Rswift.StringResource(key: "alreadySameTitleErrorMessage", tableName: "MapView", bundle: R.hostingBundle, locales: [], comment: nil)
      
      /// Value: タイトルを入力してください。
      static func inputTitleMessage(_: Void = ()) -> String {
        return NSLocalizedString("inputTitleMessage", tableName: "MapView", bundle: R.hostingBundle, comment: "")
      }
      
      /// Value: 位置情報の計測を停止しますか？
      static func stopUpdatingLocationMessage(_: Void = ()) -> String {
        return NSLocalizedString("stopUpdatingLocationMessage", tableName: "MapView", bundle: R.hostingBundle, comment: "")
      }
      
      /// Value: 位置情報の計測を停止する必要があります。
      static func needToStopUpdatingLocationErrorMessage(_: Void = ()) -> String {
        return NSLocalizedString("needToStopUpdatingLocationErrorMessage", tableName: "MapView", bundle: R.hostingBundle, comment: "")
      }
      
      /// Value: 既に同名のタイトルがあります。タイトルを変更してください。
      static func alreadySameTitleErrorMessage(_: Void = ()) -> String {
        return NSLocalizedString("alreadySameTitleErrorMessage", tableName: "MapView", bundle: R.hostingBundle, comment: "")
      }
      
      fileprivate init() {}
    }
    
    /// This `R.string.pickerView` struct is generated, and contains static references to 1 localization keys.
    struct pickerView {
      /// ja translation: キャンセル
      /// 
      /// Locales: ja
      static let s093SEuSTitle = Rswift.StringResource(key: "s09-3S-euS.title", tableName: "PickerView", bundle: R.hostingBundle, locales: ["ja"], comment: nil)
      
      /// ja translation: キャンセル
      /// 
      /// Locales: ja
      static func s093SEuSTitle(_: Void = ()) -> String {
        return NSLocalizedString("s09-3S-euS.title", tableName: "PickerView", bundle: R.hostingBundle, comment: "")
      }
      
      fileprivate init() {}
    }
    
    fileprivate init() {}
  }
  
  fileprivate struct intern: Rswift.Validatable {
    fileprivate static func validate() throws {
      try _R.validate()
    }
    
    fileprivate init() {}
  }
  
  fileprivate class Class {}
  
  fileprivate init() {}
}

struct _R: Rswift.Validatable {
  static func validate() throws {
    try nib.validate()
  }
  
  struct nib: Rswift.Validatable {
    static func validate() throws {
      try _MapViewController.validate()
    }
    
    struct _MapViewController: Rswift.NibResourceType, Rswift.Validatable {
      let bundle = R.hostingBundle
      let name = "MapViewController"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> UIKit.UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
      }
      
      static func validate() throws {
        if UIKit.UIImage(named: "Start", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'Start' is used in nib 'MapViewController', but couldn't be loaded.") }
        if UIKit.UIImage(named: "Location", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'Location' is used in nib 'MapViewController', but couldn't be loaded.") }
        if UIKit.UIImage(named: "Stop", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'Stop' is used in nib 'MapViewController', but couldn't be loaded.") }
        if UIKit.UIImage(named: "View", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'View' is used in nib 'MapViewController', but couldn't be loaded.") }
        if UIKit.UIImage(named: "Settings", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'Settings' is used in nib 'MapViewController', but couldn't be loaded.") }
        if #available(iOS 11.0, *) {
        }
      }
      
      fileprivate init() {}
    }
    
    struct _PickerView: Rswift.NibResourceType {
      let bundle = R.hostingBundle
      let name = "PickerView"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [UINib.OptionsKey : Any]? = nil) -> UIKit.UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
      }
      
      fileprivate init() {}
    }
    
    fileprivate init() {}
  }
  
  fileprivate init() {}
}

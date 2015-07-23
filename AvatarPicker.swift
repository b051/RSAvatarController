//
//  AvatarPicker.swift
//  Trusted
//
//  Created by Rex Sheng on 7/21/15.
//  Copyright (c) 2015 Trusted. All rights reserved.
//

@objc protocol AvatarPickerDelegate {
}

public class AvatarPicker {
	var _taking: Bool = false
	public var takingAvatar: Bool {
		return _taking
	}
	
	weak var imagePicker: UIImagePickerController!
	weak var delegate: AvatarPickerDelegate!
	
}
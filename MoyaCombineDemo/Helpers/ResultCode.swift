//
//  ResultCode.swift
//  ShallWeShop
//
//  Created by Inpyo Hong on 2020/03/18.
//  Copyright © 2020 Epiens Corp. All rights reserved.
//

import Foundation

enum ResultCode: String {
  case authError = "401"

  case success = "0001"
  case fail = "0002"
  case duplicate = "0003"
  case notFoundData = "0004"
  case authSendCountOver = "1001"
  case authTryCountOver = "1002"
  case notFoundUserId = "1003"
  case passwordIncorrect = "1004"
  case memberAleadyExistError = "1005"
  case snsAuthError = "1101"
  case tokenAuthError = "1403"
  case publicKeyError = "1404"
  case priceDifferentError = "2000"
  case optionDifferentError = "2001"
  case optionNotExistError = "2002"
  case outOfStockError = "2003"
  case productBlockError = "2004"
  case productDelieveryFormatError = "2005"
  case invalidChangingOrderError = "2006"
  case notExistOrder = "2007" // 주문정보가 존재하지 않음(Not exist order)
  case passwordValidityError = "3001" //기존 비밀번호와 신규 비밀번호가 같음
  case shoppingBasketMaxCountError = "3100" //장바구니 최대 횟수(100개) 초과
  case shoppingAddProductError = "3101" //장바구니 추가상품 처리 실패
  case shoppingProductOptionError = "3102" //장바구니 상품옵션 처리 실패
  case productReiewVideoError = "4101" //상품 리뷰 영상 처리 실패
  case productReiewPhotoError = "4102" //상품 리뷰 포토 처리 실패
  case packetError = "9000"
  case interlockError = "9001"
  case jsonExceptionError = "9996"
  case exceptionError = "9997"
  case dbError = "9998"
  case systemError = "9999"
}

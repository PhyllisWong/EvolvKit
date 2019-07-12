//
//  Extensions.swift
//  Alamofire
//
//  Created by phyllis.wong on 7/9/19.
//

public func getQueryStringParameter(url: String, param: String) -> String? {
  guard let url = URLComponents(string: url) else { return nil }
  return url.queryItems?.first(where: { $0.name == param })?.value
}

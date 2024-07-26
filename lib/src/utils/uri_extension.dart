/*
 *   Famedly Matrix SDK
 *   Copyright (C) 2019, 2020, 2021 Famedly GmbH
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU Affero General Public License as
 *   published by the Free Software Foundation, either version 3 of the
 *   License, or (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *   GNU Affero General Public License for more details.
 *
 *   You should have received a copy of the GNU Affero General Public License
 *   along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:core';

import 'package:matrix/src/client.dart';

extension MxcUriExtension on Uri {
  /// Transforms this `mxc://` Uri into a `http` resource, which can be used
  /// to download the content.
  ///
  /// Throws an exception if the scheme is not `mxc` or the homeserver is not
  /// set.
  ///
  /// Important! To use this link you have to set a http header like this:
  /// `headers: {"authentication": "Bearer ${client.accessToken}"}`
  Uri getAuthenticatedDownloadLink(Client client) {
    if (!isScheme('mxc')) throw Exception('Uri has unknown scheme "mxc"');
    final homeserver = client.homeserver;
    if (homeserver == null) {
      throw Exception(
          'Homeserver must be specified to generate link from mxc uri');
    }
    return homeserver.resolve(
        '_matrix/client/v1/media/download/$host${hasPort ? ':$port' : ''}$path');
  }

  /// Transforms this `mxc://` Uri into a `http` resource, which can be used
  /// to download the content with the given `width` and
  /// `height`. `method` can be `ThumbnailMethod.crop` or
  /// `ThumbnailMethod.scale` and defaults to `ThumbnailMethod.scale`.
  /// If `animated` (default false) is set to true, an animated thumbnail is requested
  /// as per MSC2705. Thumbnails only animate if the media repository supports that.
  ///
  /// Throws an exception if the scheme is not `mxc` or the homeserver is not
  /// set.
  ///
  /// Important! To use this link you have to set a http header like this:
  /// `headers: {"authentication": "Bearer ${client.accessToken}"}`
  Uri getAuthenticatedThumbnailLink(Client client,
      {num? width,
      num? height,
      ThumbnailMethod? method = ThumbnailMethod.crop,
      bool? animated = false}) {
    if (!isScheme('mxc')) throw Exception('Uri has unknown scheme "mxc"');
    final homeserver = client.homeserver;
    if (homeserver == null) {
      throw Exception(
          'Homeserver must be specified to generate link from mxc uri');
    }
    return Uri(
      scheme: homeserver.scheme,
      host: homeserver.host,
      path:
          '/_matrix/client/v1/media/thumbnail/$host${hasPort ? ':$port' : ''}$path',
      port: homeserver.port,
      queryParameters: {
        if (width != null) 'width': width.round().toString(),
        if (height != null) 'height': height.round().toString(),
        if (method != null) 'method': method.toString().split('.').last,
        if (animated != null) 'animated': animated.toString(),
      },
    );
  }

  @Deprecated('Use `getAuthenticatedDownloadLink()` instead')
  Uri getDownloadLink(Client matrix) => isScheme('mxc')
      ? matrix.homeserver != null
          ? matrix.homeserver?.resolve(
                  '_matrix/media/v3/download/$host${hasPort ? ':$port' : ''}$path') ??
              Uri()
          : Uri()
      : Uri();

  /// Returns a scaled thumbnail link to this content with the given `width` and
  /// `height`. `method` can be `ThumbnailMethod.crop` or
  /// `ThumbnailMethod.scale` and defaults to `ThumbnailMethod.scale`.
  /// If `animated` (default false) is set to true, an animated thumbnail is requested
  /// as per MSC2705. Thumbnails only animate if the media repository supports that.
  @Deprecated('Use `getAuthenticatedThumbnailLink()` instead')
  Uri getThumbnail(Client matrix,
      {num? width,
      num? height,
      ThumbnailMethod? method = ThumbnailMethod.crop,
      bool? animated = false}) {
    if (!isScheme('mxc')) return Uri();
    final homeserver = matrix.homeserver;
    if (homeserver == null) {
      return Uri();
    }
    return Uri(
      scheme: homeserver.scheme,
      host: homeserver.host,
      path: '/_matrix/media/v3/thumbnail/$host${hasPort ? ':$port' : ''}$path',
      port: homeserver.port,
      queryParameters: {
        if (width != null) 'width': width.round().toString(),
        if (height != null) 'height': height.round().toString(),
        if (method != null) 'method': method.toString().split('.').last,
        if (animated != null) 'animated': animated.toString(),
      },
    );
  }
}

enum ThumbnailMethod { crop, scale }

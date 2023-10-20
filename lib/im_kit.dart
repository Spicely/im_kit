library im_kit;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:audioplayers/audioplayers.dart' as a;
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_muka/flutter_muka.dart';
import 'package:flutter_openim_sdk_ffi/flutter_openim_sdk_ffi.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path/path.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:record/record.dart';

export 'package:popup_menu/popup_menu.dart';
export 'package:audioplayers/audioplayers.dart';

part 'src/components/im_button/im_button.dart';
part 'src/components/im_loading/im_loading.dart';
part 'src/components/im_player/im_player.dart';
part 'src/components/im_preview/im_preview.dart';
part 'src/components/voice_record/voice_record.dart';
part 'src/components/voice_record/voice_record_controller.dart';
part 'src/im_at_text/im_at_text.dart';
part 'src/im_base/im_base.dart';
part 'src/im_base/isolate_manager.dart';
part 'src/im_base/emoji.dart';
part 'src/im_theme/im_theme.dart';
part 'src/im_theme/im_chat_theme.dart';
part 'src/im_card/im_card.dart';
part 'src/im_quote/im_quote.dart';
part 'src/im_base/isolate_method.dart';
part 'src/im_file/im_file.dart';
part 'src/im_list_item/im_list_item.dart';
part 'src/im_image/im_image.dart';
part 'src/im_video/im_video.dart';
part 'src/im_voice/im_voice.dart';
part 'src/im_merger/im_merger.dart';
part 'src/im_location/im_location.dart';
part 'src/im_base/extensions.dart';

part 'src/pages/chat_page/chat_page.dart';
part 'src/pages/chat_page/chat_page_controller.dart';

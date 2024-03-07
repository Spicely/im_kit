library im_kit;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide ListTile, ButtonThemeData, Tooltip, TooltipThemeData;
import 'package:flutter/services.dart';

import 'package:audioplayers/audioplayers.dart' as a;
import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart' show Button, FluentTheme, FluentThemeData, ListTile, ListTileSelectionMode;
import 'package:flutter_muka/flutter_muka.dart';
import 'package:flutter_openim_sdk_ffi/flutter_openim_sdk_ffi.dart';
import 'package:get/get.dart' hide Response;
import 'package:html/parser.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:lottie/lottie.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path/path.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:record/record.dart';
import 'package:sprintf/sprintf.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:window_manager/window_manager.dart';

export 'package:intl/intl.dart';
export 'package:popup_menu/popup_menu.dart';
export 'package:bubble_tab_indicator/bubble_tab_indicator.dart';

part 'src/components/im_button/im_button.dart';
part 'src/components/im_loading/im_loading.dart';
part 'src/components/im_player/im_player.dart';
part 'src/components/im_preview/im_preview.dart';
part 'src/components/im_adaptive_text_selection/im_adaptive_text_selection.dart';
part 'src/components/voice_record/voice_record.dart';
part 'src/components/im_bottom_voice/im_bottom_voice.dart';
part 'src/components/voice_record/voice_record_controller.dart';
part 'src/im_at_text/im_at_text.dart';
part 'src/im_base/im_base.dart';

part 'src/im_base/isolate_manager.dart';
part 'src/im_base/emoji.dart';
part 'src/im_theme/im_theme.dart';
part 'src/im_theme/im_chat_theme.dart';
part 'src/im_theme/im_conversation_theme.dart';
part 'src/im_card/im_card.dart';
part 'src/im_quote/im_quote.dart';
part 'src/im_quote/im_quote_item.dart';
part 'src/im_custom_face/im_custom_face.dart';
part 'src/im_base/isolate_method.dart';
part 'src/im_file/im_file.dart';
part 'src/im_list_item/im_list_item.dart';
part 'src/im_image/im_image.dart';
part 'src/im_video/im_video.dart';
part 'src/im_voice/im_voice.dart';
part 'src/im_red_env/im_red_env.dart';
part 'src/im_merger/im_merger.dart';
part 'src/im_time/im_time.dart';
part 'src/im_location/im_location.dart';
part 'src/im_base/fun.dart';

part 'src/im_base/extensions.dart';
part 'src/im_base/extend_special_text_span_builder.dart';
part 'src/im_base/extensions_int_to_time.dart';

part 'src/pages/chat_page/chat_page.dart';
part 'src/pages/chat_page/chat_page_controller.dart';
part 'src/pages/conversation/conversation.dart';
part 'src/pages/conversation/conversation_controller.dart';
part 'src/pages/system_notification/system_notification_view.dart';
part 'src/pages/system_notification/system_notification_controller.dart';

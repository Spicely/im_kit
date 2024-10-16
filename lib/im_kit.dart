library im_kit;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:audioplayers/audioplayers.dart' as a;
import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_muka/flutter_muka.dart';
import 'package:flutter_openim_sdk_ffi/flutter_openim_sdk_ffi.dart';
import 'package:get/get.dart' hide Response;
import 'package:html/parser.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart' hide TextDirection;
import 'package:lottie/lottie.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path/path.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:record/record.dart';
import 'package:sprintf/sprintf.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:window_manager/window_manager.dart';

export 'package:intl/intl.dart';
export 'package:popup_menu/popup_menu.dart';
export 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
export 'package:media_kit/media_kit.dart';

part 'src/components/im_button/im_button.dart';
part 'src/components/chat_more_actions/chat_more_actions.dart';
part 'src/components/im_loading/im_loading.dart';
part 'src/components/im_player/im_player.dart';
part 'src/components/im_preview/im_preview.dart';
part 'src/components/im_adaptive_text_selection/im_adaptive_text_selection.dart';
part 'src/components/voice_record/voice_record.dart';
part 'src/components/im_bottom_voice/im_bottom_voice.dart';
part 'src/components/voice_record/voice_record_controller.dart';
part 'src/components/chat_actions/chat_actions.dart';
part 'src/im_at_text/im_at_text.dart';
part 'src/im_base/im_base.dart';

part 'src/controllers/im_controller.dart';

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
part 'src/pages/chat_page/chat_input_view.dart';
part 'src/pages/chat_page/chat_page_controller.dart';
part 'src/pages/chat_page/chat_controller_base.dart';
part 'src/pages/conversation/conversation.dart';
part 'src/pages/friends/friends_view.dart';
part 'src/pages/friends/friends_view_controller.dart';
part 'src/pages/new_friends/new_friends.dart';
part 'src/pages/new_friends/new_friends_controller.dart';
part 'src/pages/conversation/conversation_controller.dart';
part 'src/pages/system_notification/system_notification_view.dart';
part 'src/pages/system_notification/system_notification_controller.dart';

#pragma once
/*
  注：在这里定义平台层的错误码及枚举值，需要同步到三个平台的定义
  1.ios:
  2.windows:
  3.android:
*/
namespace Thunder
{
enum ThunderRet
{
  // 同步接口返回的错误码 【-1 ~ -1000】
  THUNDER_RET_SUCCESS = 0, // 成功处理
  THUNDER_RET_NOT_INITIALIZED = -1, // 没有初始化
  THUNDER_RET_WRONG_INIT_STATUS = -2, // 错误的初始化状态，在初始化或销毁未完成时再调用该类接口就会返回该错误
  THUNDER_RET_NO_JOIN_ROOM = -3, // 没有进room【仅限进频道前调用的接口，在进频道前调用会返回该错误】
  THUNDER_RET_ALREADY_JOIN_ROOM = -4, // 已进room【仅限进频道前调用的接口，在进频道后调用会返回该错误】
  THUNDER_RET_WRONG_JOIN_STATUS = -5, // 错误的登陆状态，在进频道或退出频道未完成时再调用该类接口就会返回该错误
  THUNDER_RET_NOT_IN_THUNDER = -6, // 没在Thunder模式（限Thunder调用的接口，在ThunderBolt时调用会返回该错误）
  THUNDER_RET_NOT_IN_THUNDERBOLT = -7, // 没在ThunderBolt模式（限ThunderBolt调用的接口，在Thunder时调用会返回）
  THUNDER_RET_INVALID_UID = -8, // 错误的uid
  THUNDER_RET_INVALID_ROOMID = -9, // 错误的roomId
  THUNDER_RET_INVALID_URL = -10, // 错误的url
  THUNDER_RET_INVALID_TASKID = -11, // 错误的task
  THUNDER_RET_CAPACITY_LIMIT = -12, // SDK的能力限制(推流地址超阀值等)
  THUNDER_RET_INVALID_ARGUMENT = -13, // 无效的参数(必要的参数为空或不合法时)
  THUNDER_RET_START_AUDIO_CAPTURE_ERR = -14, // 启动音频采集出错
  THUNDER_RET_NO_START_AUDIO_CAPTURE = -15, // 没启动音频采集，在没启动采集的情况下推外部数据时会返回该错误
  THUNDER_RET_ALREADY_START_AUDIO_CAPTURE = -16, // 已启动音频采集，在采集再进行设置会返回该错误码
  THUNDER_RET_NO_START_AUDIO_PUBLISH = -17, // 没启动音频开播，在没启动开播的情况下推外部数据时会返回该错误
  THUNDER_RET_ALREADY_START_AUDIO_ENCODE = -18, // 已启动音频开播，重复开播设置会返回该错误码
  THUNDER_RET_ALREADY_START_AUDIO_PUBLISH = -19, // 已启动音频开播，重复开播设置会返回该错误码
  THUNDER_RET_NOT_ON_FRONT_CAMERA = -20, // 设置摄像头镜像时，如果当前时后置设想头会返回该错误码
  THUNDER_RET_NOT_ON_MULTI_TYPE = -21, // 设置多人连麦布局的时候，如果没有在进频道前设置远端视图显示模式会返回该错误码
  THUNDER_RET_INVALID_SEATINDEX = -22, // 设置多人连麦的座位号超出设置布局的范围时会返回该错误码

  // 混画相关 【-101 ~ -200】
  THUNDER_RET_INVALID_TRANSCODING_MODE = 101, // 无效的transcoingMode

  // 异步返回的警告码 【-1001 ~ -2000】

  // 异步返回的错误码 【-2001 ~ -3000】
  THUNDER_NOTIFY_JOIN_FAIL = -2001, // 因网络等原因导致SDK没有收到服务通知进频道失败(进频道失败SDK会执行退频道操作)

  // 音频库使用的错误码 【-3001 ~ -4000】
  THUNDER_RET_AUDIO_ENGINE_ERROR = -3001, // 音频库返回错误，具体原因需要日志确认
  THUNDER_RET_AUDIO_DISABLE_VOICE_POSITION = -3002, // 未打开远端用户的语音立体声

  // 视频库使用的错误码 【-4001 ~ -5000】
  THUNDER_RET_VIDEO_ENGINE_ERROR = -4001, // 视频库返回错误，具体原因需要日志确认

  // 传输库使用的错误码 【-5001 ~ -6000】
  THUNDER_RET_TRANS_ENGINE_ERROR = -5001, // 传输库返回错误，具体原因需要日志确认

  // 配置库(argo)使用的错误码 【-6001 ~ -7000】
  THUNDER_RET_ARGO_ENGINE_ERROR = -6001, // 配置库返回错误，具体原因需要日志确认

  // SEVICE库使用的错误码 【-7001 ~ -8000】
  THUNDER_RET_SERVICE_ENGINE_ERROR = -7001, // SEVICE库返回错误，具体原因需要日志确认

  // LOG库使用的错误码 【-8001 ~ -9000】
  THUNDER_RET_LOG_ENGINE_ERROR = -8001, // 日志库返回错误，具体原因需要日志确认
};

// 地区枚举，对应接口setAreaType设置的值
enum LiveEngineAreaType
{
  THUNDER_AREA_DEFAULT = 0, // 默认值(国内)
  THUNDER_AREA_FOREIGN = 1, // 国外
  THUNDER_AREA_RESERVED = 2, // yy-reserved
};

enum LiveEngineRoomConfig
{
  THUNDER_ROOMCONFIG_LIVE = 0, // 直播 （音质高、交互模式无）（连麦时切换到音质中、交互模式强）
  THUNDER_ROOMCONFIG_COMMUNICATION = 1, // 通信 （音质中、交互模式强）
  THUNDER_ROOMCONFIG_GAME = 3, // 游戏 （音质低、交互模式强）
  THUNDER_ROOMCONFIG_MULTIAUDIOROOM = 4, // 多人语音房间 （音质中、省流量、交互模式强）
  THUNDER_ROOMCONFIG_CONFERENCE = 5, // 会议（音质中、交互模式强、适用于频繁上下麦，上下麦声音流畅不卡顿）
};

}; // namespace Thunder

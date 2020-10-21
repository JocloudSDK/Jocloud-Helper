// ThunderEngine.h

#pragma once
#ifndef THUNDER_ENGINE_H
#define THUNDER_ENGINE_H

#define YYLIVE_API_EXPORTS
#define THUNDER_ENGINE_EXPORTS

#ifdef THUNDER_ENGINE_EXPORTS
#define THUNDER_ENGINE __declspec(dllexport)
#else
#define THUNDER_ENGINE __declspec(dllimport)
#endif
/************************************************************************/
/* 术语说明：
1. 初始化：指调用initialize这个函数返回成功
2. 进房间：是指调joinRoom这个函数返回成功
3. 进房间成功：是指接收到onJoinRoomSuccess这个回调通知
/************************************************************************/
namespace Thunder
{
#define MAX_DEVICE_NAME_LEN 512 // 设备名称
#define MAX_DEVICE_DESC_LEN 512 // 设备描述
#define MAX_DEVICE_COUNT 16 // 最大设备数量
#define MAX_THUNDER_URL_LEN 512 // url长度
#define MAX_THUNDER_UID_LEN 65 // uid长度
#define MAX_THUNDER_ROOMID_LEN 65 // roomId长度
#define MAX_THUNDER_TASKID_LEN 20 // taskId长度
#define MAX_THUNDER_TRANSCODINGUSER_COUNT 9 // 最大转码画用户个数

#define MAX_THUNDER_VIDEO_BUFFER_PLANE 8 // 视频帧最大平面数(I420:3个，RGB：1个)
#define MAX_THUNDER_MIX_AUDIO_COUNT 16  // 混音流信息列表最大值
#define MAX_THUNDER_MIX_VIDEO_COUNT 16  // 混画流信息列表最大值

enum AREA_TYPE
{
  AREA_DEFAULT = 0, // 默认值（国内）
  AREA_FOREIGN = 1, // 国外
  AREA_RESERVED = 2, // reserved
};

enum THUNDER_PROFILE
{
  PROFILE_DEFAULT = 0, // 默认模式(1)
  PROFILE_NORMAL = 1, // 音视频模式
  PROFILE_ONLY_AUDIO = 2, // 纯语音模式，针对纯语音优化
};

enum ROOM_CONFIG_TYPE
{
  ROOM_CONFIG_LIVE = 0, // 直播
  ROOM_CONFIG_COMMUNICATION = 1, // 通信
  ROOM_CONFIG_GAME = 3, // 游戏
  ROOM_CONFIG_MultiAudioRoom = 4, // 多人语音房间
  ROOM_CONFIG_Conference = 5, // 会议
};

enum COMMUT_MODE
{
  COMMUT_MODE_DEFAULT = 0, // 默认=1
  COMMUT_MODE_HIGH = 1, // 强交互模式
  COMMUT_MODE_LOW = 2, // 弱交互模式
};

enum SCENARIO_MODE
{
  SCENARIO_MODE_DEFAULT = 0, // 默认=1
  SCENARIO_MODE_STABLE_FIRST, // 流畅优先：推荐注重稳定的教育
  SCENARIO_MODE_QUALITY_FIRST, // 音质优先：推荐很少或者不连麦的秀场
};

enum AUDIO_PROFILE_TYPE
{
  AUDIO_PROFILE_DEFAULT = 0, // 默认设置，NET_AAC_ELD = 38，指定44.1 KHz采样率，双声道，编码码率约 40 kbps
  AUDIO_PROFILE_SPEECH_STANDARD = 1, // NET_SILK_16K  = 2
  AUDIO_PROFILE_MUSIC_STANDARD_STEREO = 2, // NET_AACPLUS = 1
  AUDIO_PROFILE_MUSIC_STANDARD = 3, // NET_AAC_48K_MONO = 42
  AUDIO_PROFILE_MUSIC_HIGH_QUALITY_STEREO = 4, // NET_AAC_128K = 35
};

enum ThunderSourceType
{
  THUNDER_AUDIO_MIC = 0, // 仅麦克风
  THUNDER_AUDIO_FILE = 1, // 仅文件
  THUNDER_AUDIO_MIX = 2, // 麦克风和文件
  THUNDER_AUDIO_TYPE_NONE = 10, // 停止所有音频数据上行
};

/**
@brief 日志过滤器
*/
enum LOG_FILTER
{
  LOG_LEVEL_TRACE = 0,
  LOG_LEVEL_DEBUG = 1,
  LOG_LEVEL_INFO = 2,
  LOG_LEVEL_WARN = 3,
  LOG_LEVEL_ERROR = 4,
  LOG_LEVEL_RELEASE = 10,
};

/**
@brief 音频录制-文件格式
*/
enum AUDIO_RECORDING_QUALITY_TYPE
{
  AUDIO_RECORDING_QUALITY_LOW = 0, // 低音质
  AUDIO_RECORDING_QUALITY_MEDIUM = 1, // 中音质
  AUDIO_RECORDING_QUALITY_HIGH = 2, // 高音质
};

/**
 @brief 音频录制-录制质量
*/
enum AUDIO_RECORDING_FILE_TYPE
{
  AUDIO_RECORDING_WAV = 0,
  AUDIO_RECORDING_AAC = 1,
  AUDIO_RECORDING_MP3 = 2,
};

enum AUTH_RESULT
{
  AUTHRES_SUCCUSS = 0, // 鉴权成功
  AUTHRES_ERR_SERVER_INTERNAL = 10000, // 服务器内部错误，可以重试
  AUTHRES_ERR_NO_TOKEN = 10001, // 没有带token，需要调用[ updateToken:]
  AUTHRES_ERR_TOKEN_ERR = 10002, // token校验失败（数字签名不对），可能使用的appSecret不对
  AUTHRES_ERR_APPID = 10003, // token中appid跟鉴权时带的appid不一致
  AUTHRES_ERR_UID = 10004, // token中uid跟鉴权时带的uid不一致
  AUTHRES_ERR_TOKEN_EXPIRE = 10005, // token已过期
  AUTHRES_ERR_NO_APP = 10006, // app不存在，没有在管理后台注册
  AUTHRES_ERR_TOKEN_WILL_EXPIRE = 10007, // token将要过期，提前30秒通知
  AUTHRES_ERR_NO_BAND = 10008, // 用户被封禁
};

enum VideoRenderMode
{
  VIDEO_RENDER_MODE_FILL = 0, // 拉伸铺满
  VIDEO_RENDER_MODE_ASPECT_FIT = 1, // 适应窗口
  VIDEO_RENDER_MODE_CLIP_TO_BOUNDS = 2, // 裁剪铺满
};

/**
@brief 开播玩法
*/
enum VideoPublishPlayType
{
  VIDEO_PUBLISH_PLAYTYPE_SINGLE = 0, // 单人开播
  VIDEO_PUBLISH_PLAYTYPE_INTERACT = 1, // 视频连麦开播
  VIDEO_PUBLISH_PLAYTYPE_SCREENCAP = 2, // 录屏开播
};

/**
 @brief 开播档位
*/
enum VideoPublishMode
{
  VIDEO_PUBLISH_MODE_DEFAULT = -1, // 未定义，由配置自由决定开播清晰度
  VIDEO_PUBLISH_MODE_SMOOTH_DEFINITION = 1, // 标清
  VIDEO_PUBLISH_MODE_NORMAL_DEFINITION = 2, // 高清
  VIDEO_PUBLISH_MODE_HIGH_DEFINITION = 3, // 高清
  VIDEO_PUBLISH_MODE_SUPER_DEFINITION = 4, // 蓝光
  VIDEO_PUBLISH_MODE_BLUERAY = 5, // 蓝光
};

enum USER_OFFLINE_REASON_TYPE
{
  USER_OFFLINE_QUIT = 1, // 用户主动离开
  USER_OFFLINE_DROPPED = 2, // 因过长时间收不到对方数据包，超时掉线。注意：由于 SDK
                            // 使用的是不可靠通道，也有可能对方主动离开本方没收到对方离开消息而误判为超时掉线
  USER_OFFLINE_BECOME_AUDIENCE = 3, // 用户身份从主播切换为观众（直播模式下）
};

enum ThunderNetworkType
{
  THUNDER_NETWORK_TYPE_UNKNOWN = 0, // 网络连接类型未知
  THUNDER_NETWORK_TYPE_DISCONNECTED = 1, // 网络连接已断开
  THUNDER_NETWORK_TYPE_CABLE = 2, // 有线网络
  THUNDER_NETWORK_TYPE_WIFI = 3, // 无线Wi-Fi（包含热点）
  THUNDER_NETWORK_TYPE_MOBILE = 4, // 移动网络，没能区分2G,3G,4G网络
  THUNDER_NETWORK_TYPE_MOBILE_2G = 5, // 2G 移动网络
  THUNDER_NETWORK_TYPE_MOBILE_3G = 6, // 3G 移动网络
  THUNDER_NETWORK_TYPE_MOBILE_4G = 7, // 4G 移动网络
};

enum ThunderAudioDeviceStatus
{
  THUNDER_AUDIO_DEVICE_STATUS_INIT_CAPTURE_SUCCESS = 0,  // 音频采集设备初始化成功回调
  THUNDER_AUDIO_DEVICE_STATUS_INIT_CAPTURE_ERROR_OR_NO_PERMISSION = 1, // 音频采集初始化失败回调，可能是没有权限
  THUNDER_AUDIO_DEVICE_STATUS_RELEASE_CAPTURE_SUCCESS = 2, // 音频采集设备释放成功回调
};

// 网络连接状态
enum ThunderConnectionStatus
{
  THUNDER_CONNECTION_STATUS_CONNECTING = 0, // 连接中
  THUNDER_CONNECTION_STATUS_CONNECTED = 1, // 连接成功
  THUNDER_CONNECTION_STATUS_DISCONNECTED = 2, // 连接断开
};

enum ThunderVideoMirrorMode
{
  THUNDER_VIDEO_MIRROR_MODE_PREVIEW_MIRROR_PUBLISH_NO_MIRROR = 0, // 预览镜像，推流不镜像
  THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_MIRROR = 1, // 预览推流都镜像
  THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_NO_MIRROR = 2, // 预览推流都不镜像
  THUNDER_VIDEO_MIRROR_MODE_PREVIEW_NO_MIRROR_PUBLISH_MIRROR = 3, // 预览不镜像，推流镜像
};

enum NetworkQuality
{
  THUNDER_QUALITY_UNKNOWN = 0, // 质量未知
  THUNDER_QUALITY_EXCELLENT = 1, // 网络质量极好
  THUNDER_QUALITY_GOOD = 2, // 网络质量好
  THUNDER_QUALITY_POOR = 3, // 网络质量较好，用户感受有瑕疵但不影响沟通
  THUNDER_QUALITY_BAD = 4, // 网络质量一般，勉强能沟通但不顺畅
  THUNDER_QUALITY_VBAD = 5, // 网络质量非常差，基本不能沟通
  THUNDER_QUALITY_DOWN = 6 // 网络断开连接，完全无法沟通
};

enum ThunderCaptureStatus
{
  THUNDER_VIDEO_CAPTURE_STATUS_SUCCESS = 0, // 成功
  THUNDER_VIDEO_CAPTURE_STATUS_AUTHORIZED = 1, // 用户还没给权限【PC暂不支持】
  THUNDER_VIDEO_CAPTURE_STATUS_NOT_DETERMINED = 2, // 还没给权限【PC暂不支持】
  THUNDER_VIDEO_CAPTURE_STATUS_RESTRICTED = 3, // 被占用
  THUNDER_VIDEO_CAPTURE_STATUS_DENIED = 4, // 无权限
  THUNDER_VIDEO_CAPTURE_STATUS_CLOSE = 5, // 关闭
  THUNDER_VIDEO_CAPTURE_STATUS_LOST = 6, // 设备拔出
  THUNDER_VIDEO_CAPTURE_STATUS_RESUME = 7, // 设备拔出后恢复
};

/**
 @brief onRecordAudioFrame 的使用模式
*/
enum ThunderAudioRawFrameOperationMode
{
	THUNDER_AUDIO_RAW_FRAME_OPERATION_MODE_READ_ONLY = 1, // 只读模式，用户仅从 AudioFrame 获取原始数据
	THUNDER_AUDIO_RAW_FRAME_OPERATION_MODE_WRITE_ONLY = 2, // 只写模式，用户替换 AudioFrame 中的数据以供 SDK 编码传输
	THUNDER_AUDIO_RAW_FRAME_OPERATION_MODE_READ_WRITE = 3, // 读写模式，用户从 AudioFrame 获取并修改数据，并返回给 SDK 进行编码传输
};

enum MEDIA_DEVICE_TYPE
{
	/** -1: Unknown device type.
	*/
	UNKNOWN_AUDIO_DEVICE = -1,
	/** 0: Audio playback device.
	*/
	AUDIO_PLAYOUT_DEVICE = 0,
	/** 1: Audio recording device.
	*/
	AUDIO_RECORDING_DEVICE = 1,
	/** 2: Video renderer.
	*/
	VIDEO_RENDER_DEVICE = 2,
	/** 3: Video capturer.
	*/
	VIDEO_CAPTURE_DEVICE = 3,
	/** 4: Application audio playback device.
	*/
	AUDIO_APPLICATION_PLAYOUT_DEVICE = 4,
};

/** Media device states.
*/
enum MEDIA_DEVICE_STATE_TYPE
{
	/** 1: The device is active.
	*/
	MEDIA_DEVICE_STATE_ACTIVE = 1,
	/** 2: The device is disabled.
	*/
	MEDIA_DEVICE_STATE_DISABLED = 2,
	/** 4: The device is not present.
	*/
	MEDIA_DEVICE_STATE_NOT_PRESENT = 4,
	/** 8: The device is unplugged.
	*/
	MEDIA_DEVICE_STATE_UNPLUGGED = 8
};

// 远端音频流状态
enum REMOTE_AUDIO_STATE
{
	// 远端音频流默认初始状态。 在 THUNDER_REMOTE_AUDIO_REASON_LOCAL_STOPPED(4) 或 THUNDER_REMOTE_AUDIO_REASON_REMOTE_STOPPED(6)  的情况下，会报告该状态
	THUNDER_REMOTE_AUDIO_STATE_STOPPED = 0,
	THUNDER_REMOTE_AUDIO_STATE_STARTING = 1, // 本地用户已接收远端音频首包
	THUNDER_REMOTE_AUDIO_STATE_DECODING = 2, // 远端音频流正在解码，正常播放
	THUNDER_REMOTE_AUDIO_STATE_FROZEN = 3, // 远端音频流卡顿。在 THUNDER_REMOTE_AUDIO_REASON_NETWORK_CONGESTION(2) 的情况下，会报告该状态
	// 远端音频流播放失败。在 THUNDER_REMOTE_AUDIO_REASON_INTERNAL(1) 的情况下，会报告该状态
	// THUNDER_REMOTE_AUDIO_STATE_FAILED = 4; (暂未实现)
};

// 远端音频流状态改变的原因
enum REMOTE_AUDIO_REASON
{
	THUNDER_REMOTE_AUDIO_REASON_OK = 0, // 状态正常
	THUNDER_REMOTE_AUDIO_REASON_INTERNAL = 1, // 内部原因
	THUNDER_REMOTE_AUDIO_REASON_NETWORK_CONGESTION = 2, // 网络阻塞
	THUNDER_REMOTE_AUDIO_REASON_NETWORK_RECOVERY = 3, // 网络恢复正常
	THUNDER_REMOTE_AUDIO_REASON_LOCAL_STOPPED = 4, // 本地用户停止接收远端音频流或本地用户禁用音频模块
	THUNDER_REMOTE_AUDIO_REASON_LOCAL_STARTED = 5, // 本地用户恢复接收远端音频流或本地用户启用音频模块
	THUNDER_REMOTE_AUDIO_REASON_REMOTE_STOPPED = 6, // 远端用户停止发送音频流或远端用户禁用音频模块
	THUNDER_REMOTE_AUDIO_REASON_REMOTE_STARTED = 7, // 远端用户恢复发送音频流或远端用户启用音频模块
};

// 远端视频流状态
enum REMOTE_VIDEO_STATE
{
  THUNDER_REMOTE_VIDEO_STATE_STOPPED = 0, // 远端视频默认初始状态。在 THUNDER_REMOTE_VIDEO_REASON_LOCAL_STOPPED(4) 或 THUNDER_REMOTE_VIDEO_REASON_REMOTE_STOPPED(6) 的情况下，会报告该状态
  THUNDER_REMOTE_VIDEO_STATE_STARTING = 1, // 本地用户已接收远端视频首包
  THUNDER_REMOTE_VIDEO_STATE_DECODING = 2, // 远端视频流正在解码
  THUNDER_REMOTE_VIDEO_STATE_RENDERING = 3, // 远端视频流正在渲染
  THUNDER_REMOTE_VIDEO_STATE_FROZEN = 4, // 远端视频流卡顿。在 THUNDER_REMOTE_VIDEO_REASON_NETWORK_CONGESTION(2) 的情况下，会报告该状态
};

// 远端视频流状态改变的原因
enum REMOTE_VIDEO_REASON
{
  THUNDER_REMOTE_VIDEO_REASON_OK = 0, // 状态正常
  THUNDER_REMOTE_VIDEO_REASON_INTERNAL = 1, // 内部原因
  THUNDER_REMOTE_VIDEO_REASON_NETWORK_CONGESTION = 2, // 网络阻塞
  THUNDER_REMOTE_VIDEO_REASON_NETWORK_RECOVERY = 3, // 网络恢复正常
  THUNDER_REMOTE_VIDEO_REASON_LOCAL_STOPPED = 4, // 本地用户停止接收远端视频流或本地用户禁用视频模块
  THUNDER_REMOTE_VIDEO_REASON_LOCAL_STARTED = 5, // 本地用户恢复接收远端视频流或本地用户启动视频模块
  THUNDER_REMOTE_VIDEO_REASON_REMOTE_STOPPED = 6, // 远端用户停止发送视频流或远端用户禁用视频模块
  THUNDER_REMOTE_VIDEO_REASON_REMOTE_STARTED = 7, // 远端用户恢复发送视频流或远端用户启用视频模块
};

// 本地视频流状态
enum LOCAL_VIDEO_STREAM_STATUS
{
  THUNDER_LOCAL_VIDEO_STREAM_STATUS_STOPPED = 0, // 本地视频默认初始状态
  THUNDER_LOCAL_VIDEO_STREAM_STATUS_CAPTURING = 1, // 本地视频采集设备启动成功
  THUNDER_LOCAL_VIDEO_STREAM_STATUS_PREVIEWING = 2, // 本地视频预览成功
  THUNDER_LOCAL_VIDEO_STREAM_STATUS_ENCODING = 3, // 本地视频首帧编码成功
  THUNDER_LOCAL_VIDEO_STREAM_STATUS_SENDING = 4, // 本地视频首帧发送成功
  THUNDER_LOCAL_VIDEO_STREAM_STATUS_FAILED = 5, // 本地视频启动失败
};

// 本地视频流状态改变的原因
enum LOCAL_VIDEO_STREAM_ERROR_REASON
{
  THUNDER_LOCAL_VIDEO_STREAM_ERROR_OK = 0, // 本地视频状态正常
  THUNDER_LOCAL_VIDEO_STREAM_ERROR_FAILURE = 1, // 出错原因不明确
  THUNDER_LOCAL_VIDEO_STREAM_ERROR_DEVICE_DENIED = 2, // 没有权限启动本地视频采集设备
  THUNDER_LOCAL_VIDEO_STREAM_ERROR_DEVICE_RESTRICTED = 3, // 本地视频采集设备正在使用中
  THUNDER_LOCAL_VIDEO_STREAM_ERROR_CAPTURE_FAILURE = 4, // 本地视频采集失败，建议检查采集设备是否正常工作
  THUNDER_LOCAL_VIDEO_STREAM_ERROR_ENCODE_FAILURE = 5, // 本地视频编码失败
};

// 检测系统是否支持某些特性
enum FEATURE_SUPPORT
{
    FEATURE_SUPPORT_MAGAPI = 0,  //是否支持Mag API捕捉
};

// 本地文件播放事件的各种状态
enum ThunderAudioFilePlayerEvent
{
	AUDIO_PLAY_EVENT_OPEN = 1, // 打开文件
	AUDIO_PLAY_EVENT_PLAY = 2, // 开始播放
	AUDIO_PLAY_EVENT_STOP = 3, // 停止播放
	AUDIO_PLAY_EVENT_PAUSE = 4, // 暂停播放
	AUDIO_PLAY_EVENT_RESUME = 5, // 恢复播放
	AUDIO_PLAY_EVENT_END = 6, // 播放完毕
	AUDIO_PLAY_EVENT_SEEK_COMPLETE = 7, // 快进播放
};

// 本地文件播放事件的错误码
enum ThunderAudioFilePLayerErrorCode
{
	AUDIO_PLAYER_OPEN_FILE_PATH_ERROR = -4, // 文件路径错误
	AUDIO_PLAYER_OPEN_FILE_FORMAT_NOT_SUPPORT = -3, // 文件格式不支持
	AUDIO_PLAYER_OPEN_FILE_DECODER_FAILED = -2, // 文件格式解码出错
	AUDIO_PLAYER_CREATE_FILE_DECODER_FAILED = -1, // 文件格式解析出错
	AUDIO_PLAYER_STATUS_SUCCESS = 0, // 成功
};

class IAudioFrameObserver
{
public:
	enum AUDIO_FRAME_TYPE
	{
		FRAME_TYPE_PCM16 = 0, // PCM 16bit little endian
	};

	struct AudioFrame
	{
		AUDIO_FRAME_TYPE type;

		int samples; // 该帧的样本数量
		int bytesPerSample; // 每个样本的字节数：PCM（16位）含两个字节
		int channels; // 频道数量（如果是立体声，数据是交叉的）；1：单声道，2：双声道
		int samplesPerSec; // 采样率
		void* buffer; // data buffer

		long long renderTimeMs; // 暂未用
		int avsync_type; // 暂未用
	};

public:
	virtual ~IAudioFrameObserver() {}

	// 音频采集原始数据回调
	virtual bool onRecordAudioFrame(AudioFrame& audioFrame) = 0;
	// 音频播放原始数据回调
	virtual bool onPlaybackAudioFrame(AudioFrame& audioFrame) = 0;
	// 音频远端用户解码后原始数据回调
	virtual bool onPlaybackAudioFrameBeforeMixing(char* uid, AudioFrame& audioFrame) = 0;
};

struct AudioDeviceInfo // 音频设备信息
{
  GUID id; // 音频设备标识
  char name[MAX_DEVICE_NAME_LEN]; // 音频设备名称
  char desc[MAX_DEVICE_DESC_LEN]; // 音频设备描述
};

struct AudioDeviceList
{
  AudioDeviceInfo device[MAX_DEVICE_COUNT]; // 音频设备列表
  int count; // 音频设备个数
};

struct AudioVolumeInfo
{
  char uid[MAX_THUNDER_UID_LEN]; // 用户id
  int volume; // 音量
};

struct AudioFrame
{
  int samples; // 音频采样率（sampleRate）
  int bytesPerSample; // 比特率
  int channels; // 音频声道
  int samplesPerSec; // 采样点位宽(目前只支持16)
  int bufLen; // 数据长度
  void* buffer; // 具体数据
};

enum VIDEO_FRAME_TYPE
{
  FRAME_TYPE_YUV420 = 0, // YUV420
  FRAME_TYPE_BGRA = 30,
};

struct VideoFrame
{
  void* dataPtr[MAX_THUNDER_VIDEO_BUFFER_PLANE]; // 视频帧各平面数据指针
  int dataLength[MAX_THUNDER_VIDEO_BUFFER_PLANE]; // 视频帧各平面数据长度
  int dataStride[MAX_THUNDER_VIDEO_BUFFER_PLANE]; // 视频帧各平面数据步长
  int width; // 视频帧宽度
  int height; // 视频帧宽高度
  VIDEO_FRAME_TYPE type; // 视频帧类型
  int rotation; // 旋转角度
  __int64 timeStamp; // 显示时间戳
};

struct VideoDeviceInfo
{
  char name[MAX_DEVICE_NAME_LEN]; // 视频设备名称
  int index; // 视频设备索引
};

struct VideoDeviceList
{
  VideoDeviceInfo device[MAX_DEVICE_COUNT]; // 视频设备列表
  int count; // 视频设备个数
};

struct MonitorDeviceInfo
{
  int index; // 获取到的设备编号
  int flags; // 屏幕属性的标志 。下表列出了可能的值:
             // 0 : 此屏幕不是主屏幕。
             // 1 : 此屏幕是主屏幕，注也可以用windows自带宏MONITORINFOF_PRIMARY标识
  void* handle; // pHandler to display monitor <==> HMONITOR
  RECT rcWork; // 指定屏幕的工作区域矩形，以虚拟屏幕坐标表示
  RECT rcMonitor; // 指定屏幕矩形，以虚拟屏幕坐标表示
  char name[MAX_DEVICE_NAME_LEN]; // 设备名称
};

struct MonitorDeviceList
{
  int count; // 视频设备个数
  MonitorDeviceInfo device[MAX_DEVICE_COUNT]; // 视频设备列表
};

struct VideoEncoderConfiguration
{
  VideoPublishPlayType playType;
  VideoPublishMode publishMode;
};

struct VideoCanvas
{
  HWND hWnd;  // 视频渲染窗口
  VideoRenderMode renderMode; // 视频渲染模式
  char uid[MAX_THUNDER_UID_LEN]; // 用户id
};

struct FirstRenderInfo
{
  HWND hwnd; // 视频渲染窗口
  unsigned long timeStamp; // 视频渲染时间
};

struct CustomAudioOptions
{
  int sampleRate; // 采样率(48k,44.1,16k,8k)
  int channels; // 音频通道
  int bitpersample; // 采样点位宽(目前只支持16)
  bool bMixSdkCapture; // 是否合成SDK本身的采集
};

struct CustomVideoOptions
{
  enum CustomVideoSrcDataType
  {
    DATA_TYPE_I420 = 0,
    DATA_TYPE_NV12 = 1,
    DATA_TYPE_BGR24 = 2,
    DATA_TYPE_BGRA = 3,
  };

  int srcWidth; // 输入源的宽高 【不支持动态更新】
  int srcHeight; // 输入源的高度 【不支持动态更新】
  int destWidth; // 输出流的宽高 【该参数已废弃，需要根据setVideoEncoderConfig这个接口设置】
  int destHeight; // 输出流的宽高 【该参数已废弃，需要根据setVideoEncoderConfig这个接口设置】
  int codeRate; // 具体的码率值，单位kbps 【该参数已废弃，需要根据setVideoEncoderConfig这个接口设置】
  CustomVideoSrcDataType srcDataType; // 源流数据类型
};

struct ThunderBoltImage
{
  int x; // 以左上角为原点 横轴坐标
  int y; // 以左上角为原点 纵轴坐标
  int width; // 宽度
  int height; // 高度
  char url[MAX_THUNDER_URL_LEN]; // 本地图片的绝对路径地址或http、https地址
};

struct TranscodingUser
{
  TranscodingUser()
    : bStandard(false)
    , layoutX(0)
    , layoutY(0)
    , layoutW(0)
    , layoutH(0)
    , zOrder(0)
    , bCrop(false)
    , cropX(0)
    , cropY(0)
    , cropW(0)
    , cropH(0)
    , alpha(0)
    , audioChannel(0)
  {
  }

  bool bStandard; // 是否基准流用户
  int layoutX; // 用户在混画画布中的x位置
  int layoutY; // 用户在混画画布中的y位置
  int layoutW; // 用户在混画画布中的宽度
  int layoutH; // 用户在混画画布中的高度
  int zOrder; // 直播视频上用户视频帧的图层编号,取值范围为 [0, 100] 中的整型(0=最底层，1=从下往上数第一层，其他类推)
  bool bCrop; // 0:画面缩放后居中显示，上下/左右两侧补黑边;1:画面缩放后居中裁剪,裁去上下/左右多余区域
  int cropX; // 裁剪区域x坐标，不填默认居中裁剪
  int cropY; // 裁剪区域Y坐标
  int cropW; // 裁剪区域宽度
  int cropH; // 裁剪区域高度
  float alpha; // 直播视频上用户视频的透明度。取值范围为 [0.0, 1.0]。0.0 表示该区域图像完全透明，而 1.0
               // 表示该区域图像完全不透明。默认值为 1.0
  int audioChannel; // 暂未实现
  char uid[MAX_THUNDER_UID_LEN];
  char roomId[MAX_THUNDER_ROOMID_LEN];
};

struct LiveTranscoding
{
  // 音频默认统一为："encode": 1,"bitrate":128,"sample":44100,"channel":2
  enum TranscodingMode
  {
    TRANSCODING_MODE_320X180 = 1, // "encode":100,"bitrate":150,"fps":15,"gop":30,"height":180,"width":320
    TRANSCODING_MODE_320X240 = 2, // "encode":100,"bitrate":200,"fps":15,"gop":30,"height":240,"width":320
    TRANSCODING_MODE_640X360 = 3, // "encode":100,"bitrate":500,"fps":15,"gop":30,"height":360,"width":640
    TRANSCODING_MODE_640X480 = 4, // "encode":100,"bitrate":500,"fps":15,"gop":30,"height":480,"width":640
    TRANSCODING_MODE_960X544 = 5, // "encode":100,"bitrate":1000,"fps":24,"gop":48,"height":544,"width":960
    TRANSCODING_MODE_1280X720 = 6, // "encode":100,"bitrate":1600,"fps":24,"gop":48,"height":720,"width":1280
    TRANSCODING_MODE_1920X1080 = 7, // "encode":100,"bitrate":4500,"fps":24,"gop":48,"height":1080,"width":1920
  };

  LiveTranscoding() : transcodingMode(0), userCount(0) {}

  int transcodingMode; // 转码档位(enum TranscodingMode)
  int userCount;
  TranscodingUser userList[MAX_THUNDER_TRANSCODINGUSER_COUNT];
};

enum ThunderPublishCDNErrorCode
{
  THUNDER_PUBLISH_CDN_ERR_SUCCESS = 0, // 推流成功
  THUNDER_PUBLISH_CDN_ERR_TOCDN_FAILED = 1, // 推流到外部服务器(CDN)失败。1.请检查url是否正确 2.
                                            // 检查url中token是否有效（通常cdn推流需要带token，若不存在token可忽略）
  THUNDER_PUBLISH_CDN_ERR_THUNDERSERVER_FAILED =
    2, // 推流到thunder内部服务器失败。1. 检查主播上行网络 2. 联系我们排查内部传输问题
  THUNDER_PUBLISH_CDN_ERR_THUNDERSERVER_STOP = 3, // 停止推流
};

struct RoomStats
{
  int totalDuration; // 加入频道后累计通话时长,单位为秒
  int txBitrate; // 链路发送码率，单位bps
  int rxBitrate; // 链路接收码率，单位bps
  int txBytes; // 加入频道后累计发送字节数
  int rxBytes; // 加入频道后累计接收字节数
  int txAudioBytes; // 加入频道后累计发送音频字节数
  int rxAudioBytes; // 加入频道后累计接收音频字节数
  int txVideoBytes; // 加入频道后累计发送视频字节数
  int rxVideoBytes; // 加入频道后累计接收视频字节数
  int txAudioBitrate; // 音频包的发送码率，单位bps
  int rxAudioBitrate; // 音频包的接收码率，单位bps
  int txVideoBitrate; // 视频包的发送码率，单位bps
  int rxVideoBitrate; // 视频包的接收码率，单位bps
  int lastmileDelay;  // 本地客户端到边缘服务器的延迟（毫秒)，音频和视频延时中的较大值
};

enum ThunderSendAppMsgDataFailedStatus
{
  THUNDER_SEND_APP_DATA_HIGHT_FREQUENCY = 1, // 发送频率太高，每秒不超过2次
  THUNDER_SEND_APP_DATA_LARGE_MSG_DATA = 2, // 每次发送数据太大，每次不能超过200Byte
  THUNDER_SEND_APP_DATA_NO_PUBLISH_SUCCESS = 3, // 未成功开播
};

enum VIDEO_CODEC_TYPE
{
  VIDEO_CODEC_UNKNOW = 0,
  VIDEO_CODEC_VP8 = 1,      //标准 VP8
  VIDEO_CODEC_H264 = 2,     //标准 H264
  VIDEO_CODEC_H265 = 3,     //标准 H265
  VIDEO_CODEC_EVP = 4,      //增强 VP8
  VIDEO_CODEC_E264 = 5,     //增强 H264
};

enum VIDEO_ENCODED_TYPE
{
  VIDEO_ENCODED_TYPE_UNKNOWN = 0,
  VIDEO_ENCODED_TYPE_HARD = 1, // 硬编
  VIDEO_ENCODED_TYPE_SOFT = 2, // 软编
};

enum QUALITY_ADAPT_INDICATION
{
  ADAPT_NONE = 0,           //本地视频质量不变
  ADAPT_UP_BANDWIDTH = 1,   //因网络带宽增加，本地视频质量改善
  ADAPT_DOWN_BANDWIDTH = 2, //因网络带宽减少，本地视频质量变差
};

struct LocalVideoStats
{
  int sendBitrate;// 实际发送码率，单位为 Kbps，不包含丢包后重传视频等的发送码率
  int sendFrameRate;// 实际发送帧率，单位为 fps，不包含丢包后重传视频等的发送帧率
  int encoderOutputFrameRate;// 本地编码器的输出帧率，单位为 fps
  int rendererOutputFrameRate;// 本地预览的输出帧率，单位为 fps
  int targetBitrate;// 当前编码器的目标编码码率，单位为 Kbps，该码率为 SDK 根据当前网络状况预估的一个值
  int targetFrameRate;// 当前编码器的目标编码帧率，单位为 fps, 该帧率为算法SDK 根据当前网络状况预估的一个值
  QUALITY_ADAPT_INDICATION qualityAdaptIndication;//自上次统计后本地视频质量的自适应情况（基于目标帧率和目标码率） 
  int encodedBitrate;//视频编码码率（Kbps）。该参数不包含丢包后重传视频等的编码码率
  int encodedFrameWidth;// 视频编码宽度（px)
  int encodedFrameHeight;// 视频编码高度（px）
  int encodedFrameCount;// 视频发送的帧数，累计值
  VIDEO_ENCODED_TYPE encodedType;// 编码形式
  VIDEO_CODEC_TYPE codecType;// 视频的编码类型
  int configBitRate;//配置码率 kbps
  int configFrameRate;// 配置帧率
  int configWidth;// 配置编码宽度
  int configHeight;// 配置编码高度
};

struct LocalAudioStats 
{
  int encodeBitrate; // 编码码率kbps
  int numChannels;    // 声道数
  int sendSampleRate; // 发送的采样率，单位为 Hz
  int sendBitrate;    // 发送码率的平均值，单位为 Kbps
  int enableVad; // 发送的音频流采用的VAD，0：不开启；1：开启
};

enum REMOTE_VIDEO_STREAM_TYPE
{
  REMOTE_VIDEO_STREAM_HIGH = 0,  // 大流
  REMOTE_VIDEO_STREAM_LOW = 1,   // 小流
};

struct RemoteVideoStats
{
  int delay; // 远端视频推流到播放的延时
  int width; // 远端视频流宽度
  int height; // 远端视频流高度
  int receivedBitrate; // 接收码率，单位为Kbps
  int decoderOutputFrameRate; // 远端视频解码器的输出帧率，单位为fps
  int rendererOutputFrameRate; // 远端视频渲染器的输出帧率，单位为fps
  int packetLossRate; // 远端视频在网络对抗之后的丢包率(%)
  REMOTE_VIDEO_STREAM_TYPE rxStreamType; // 视频流类型，大流或小流
  int totalFrozenTime; // 远端用户在加入频道后发生视频卡顿的累计时长(ms)
  int frozenRate; // 远端用户在加入频道后发生视频卡顿的累计时长占视频总有效时长的百分比(%)
};

struct RemoteAudioStats
{
    int quality;// 远端用户发送的音频流质量。0：质量未知；1：质量极好；2：质量好；3：质量较好，用户感受有瑕疵但不影响沟通；4：质量一般，勉强能沟通但不顺畅；5：质量非常差，基本不能沟通；6：连接已断开，完全无法沟通 
    int networkTransportDelay;// 音频发送端到接收端的网络延时
    int jitterBufferDelay;// 接收端到出网络抖动缓冲的延时
    int totalDelay;// 主播采集音频到观众播放音频的总延时
    int frameLossRate;// 远端音频流的丢帧率（%）
    int numChannels;// 声道数
    int receivedSampleRate;// 远端音频的采样率（Hz）
    int receivedBitrate;// 统计周期内远端音频的平均码率
    int totalFrozenTime;// 远端用户加入频道后发生音频卡顿的累计时长（ms）
    int frozenRate;// 远端用户加入频道后发生音频卡顿的累计时长占音频总有效时长的百分比（%）
};

struct ThunderVideoEncodeParam
{
	int width; // 编码宽
	int height; // 编码高
	int frameRate; // 编码码率
	int codeRate; // 编码帧率
};

struct DeviceStats
{
  double cpuTotalUsage; // 当前系统的 CPU 使用率(%)
  double cpuAppUsage; // 当前 App 的 CPU 使用率 (%)
  double memoryAppUsage; // 当前 App 的内存占比 (%)
  double memoryTotalUsage; // 当前系统的内存占比 (%)
};

enum LOCAL_AUDIO_STREAM_STATUS
{
  THUNDER_LOCAL_AUDIO_STREAM_STATUS_STOPPED = 0, // 本地音频默认初始状态
  THUNDER_LOCAL_AUDIO_STREAM_STATUS_CAPTURING = 1, // 本地音频录制设备启动成功
  THUNDER_LOCAL_AUDIO_STREAM_STATUS_ENCODING = 2, // 本地音频首帧编码成功
  THUNDER_LOCAL_AUDIO_STREAM_STATUS_SENDING = 3, // 本地音频首帧发送成功
  THUNDER_LOCAL_AUDIO_STREAM_STATUS_FAILED = 4, // 本地音频启动/发送失败
};

enum LOCAL_AUDIO_STREAM_ERROR_REASON
{
  THUNDER_LOCAL_AUDIO_STREAM_ERROR_OK = 0, // 状态正常
  THUNDER_LOCAL_AUDIO_STREAM_ERROR_FAILURE = 1, // 本地音频错误原因未知
  THUNDER_LOCAL_AUDIO_STREAM_ERROR_DEVICE_DENIED = 2, // 没有权限启动本地音频录制设备
  THUNDER_LOCAL_AUDIO_STREAM_ERROR_DEVICE_RESTRICTED = 3, // 本地音频录制设备已经在使用中
  THUNDER_LOCAL_AUDIO_STREAM_ERROR_CAPTURE_FAILURE = 4, // 本地音频录制失败
  THUNDER_LOCAL_AUDIO_STREAM_ERROR_ENCODE_FAILURE = 5, // 本地音频编码失败
};

// 回调
class IThunderEventHandler
{
 public:
  virtual ~IThunderEventHandler() {}

  /**
  @brief 进房间成功通知
  @param [OUT] roomId 房间号
  @param [OUT] uid  用户id
  @param [OUT] elapsed 表示进房间耗时，从调用joinRoom到发生此事件经过的时间（毫秒）
  @remark 调用joinRoom后，收到此通知表示与服务器连接正常，可以调用需要"进房间成功"才能调用的接口
  */
  virtual void onJoinRoomSuccess(const char* roomId, const char* uid, int elapsed) {}

  /**
  @brief 离开房间通知
  @remark 调用leaveRoom，正常退出房间就会收到此通知
  */
  virtual void onLeaveRoom() {}

  /**
  @brief 播放音量通知
  @param [OUT] speakers 说话者
  @param [OUT] speakerCount 说话者个数
  @param [OUT] totalVolume (混音后的)总音量 [0-100]
  @remark 设置setAudioVolumeIndication后，房间内有人说话就会收到该通知
  */
  virtual void onPlayVolumeIndication(const AudioVolumeInfo* speakers, int speakerCount, int totalVolume) {}

  /**
  @brief 试音输入音量通知
  @param [OUT] volume 音量值
  @remark 调用startInputDeviceTest会收到此通知，通知频率为120毫秒
  */
  virtual void onInputVolume(unsigned volume) {}

  /**
  @brief 试音输出音量通知
  @param [OUT] volume 音量值
  @remark 调用startOutputDeviceTest会收到此通知，通知频率为150毫秒
  */
  virtual void onOutputVolume(unsigned volume) {}

  /**
  @brief 业务鉴权结果通知
  @param [OUT] bPublish 是否开播（作为主播说话）
  @param [OUT] result 鉴权结果 ：0表示成功，其他值表示失败（由开发者自定义，sdk只透传）
  @remark 当业务配置了需要业务鉴权，当媒体流上行时，就会收到该通知
  */
  virtual void onBizAuthResult(bool bPublish, AUTH_RESULT result) {}

  /**
  @brief SDK鉴权结果通知 关于鉴权详见官网的"用户鉴权说明"
  @param [OUT] result 鉴权结果
  @remark 调用joinRoom之后，有上下行媒体数据，就会收到该用户的鉴权通知
  */
  virtual void onSdkAuthResult(AUTH_RESULT result) {}

  /**
  @brief token 即将过期通知
  @remark 用户的token快过期时会收到该通知
  */
  virtual void onTokenWillExpire(const char* token) {}

  /**
  @brief token 过期通知
  @remark 用户的token已过期时会收到该通知
  */
  virtual void onTokenRequest() {}

  /**
  @brief 用户被封禁通知
  @param [OUT] status 封禁状态 ture:封禁 false:解禁
  @remark 用户的封禁状态变化时会收到该通知
  */
  virtual void onUserBanned(bool status) {}

  /**
  @brief 用户加入当前房间通知
  @param [OUT] uid 用户 ID
  @param [OUT] elapsed 实耗时间，从调用joinRoom到发生此事件经过的时间（毫秒）
  @remark 本地用户进房间后，有其它用户再进入该房间就会收到该通知，只在纯音频模式下生效
  */
  virtual void onUserJoined(const char* uid, int elapsed) {}

  /**
  @brief 用户离开当前房间通知
  @param [OUT] uid 用户 ID
  @param [OUT] reason 离线原因
  @remark 本地用户进房间后，有其它用户退出该房间就会收到该通知，只在纯音频模式下生效
  */
  virtual void onUserOffline(const char* uid, USER_OFFLINE_REASON_TYPE reason) {}

  /**
  @brief 用户的网络上下行质量报告通知
  @param [OUT] uid 用户 ID
  @param [OUT] txQuality 该用户的上行网络质量
  @param [OUT] rxQuality 该用户的下行网络质量
  */
  virtual void onNetworkQuality(const char* uid, NetworkQuality txQuality, NetworkQuality rxQuality) {}

  /**
  @brief 成功发送本地视频首帧通知
  @param [OUT] elapsed 实耗时间，从调用joinRoom到发生此事件经过的时间（毫秒）
  @remark 用户上行视频流，就会收到该通知
  */
  virtual void onFirstLocalVideoFrameSent(int elapsed) {}

  /**
  @brief 成功发送本地音频首帧通知
  @param [OUT] elapsed 实耗时间，从调用joinRoom到发生此事件经过的时间（毫秒）
  @remark 用户上行音频流，就会收到该通知
  */
  virtual void onFirstLocalAudioFrameSent(int elapsed) {}

  /**
  @brief 远端用户音频流开启/停止通知
  @param [OUT] uid 用户id
  @param [OUT] stop true:音频流停止 false:音频流开启
  @remark 调用joinRoom后，房间存的音频流及后续音频流状态发生变化时就会收到该通知
  */
  virtual void onRemoteAudioStopped(const char* uid, bool stop) {}

  /**
  @brief 跟服务器网络连接状态通知
  @param [OUT] status 网络连接状态
  @remark 调用joinRoom后，SDK与服务器网络连接状态发生变化时会收到该通知
  */
  virtual void onConnectionStatus(ThunderConnectionStatus status) {}

  /**
  @brief 跟服务器网络连接中断通知
  @remark 调用joinRoom后，SDK与服务器网络连接中断会收到该通知
  */
  virtual void onConnectionLost() {}

  /**
  @brief 远端用户视频流开启/停止通知
  @param [OUT] uid 用户id
  @param [OUT] stop true:视频流停止 false:视频流开启
  @remark 调用joinRoom后，房间存的视频流及后续视频流状态发生变化时就会收到该通知
  */
  virtual void onRemoteVideoStopped(const char* uid, bool stop) {}

  /**
  @brief 本地或远端视频分辨率改变通知
  @param [OUT] uid 用户id
  @param [OUT] width 宽
  @param [OUT] height 高
  @param [OUT] rotation  预留定义，未实现
  @remark 调用joinRoom后，视频分辨率发生变化时就会收到该通知
  */
  virtual void onVideoSizeChanged(const char* uid, int width, int height, int rotation) {}

   /**
  @brief 已显示远端视频首帧通知
  @param [OUT] uid 用户id
  @param [OUT] width 宽
  @param [OUT] height 高
  @param [OUT] elapsed 实耗时间，从调用joinRoom到发生此事件经过的时间（毫秒）
  @remark 调用setRemoteVideoCanvas后，在收到视频流并在窗口显示时，会收到该通知
  */
  virtual void onRemoteVideoPlay(const char* uid, int width, int height, int elapsed) {}

  /**
 @brief 网络状态化通知
  @param [OUT] type 当前网络状态
  @remark "初始化"后，当网络类型发生变化时，会收到该通知
  */
  virtual void onNetworkTypeChanged(ThunderNetworkType type) {}

  /**
  @brief 音频设备采集状态变化通知
  @param [OUT] type 音频设备采集状态
  @remark 启动音频采集，当音频采集设备状态发生变化时，会收到该通知
  */
  virtual void onAudioCaptureStatus(ThunderAudioDeviceStatus type) {}

  /**
  @brief 音频设备插拔行为状态回调，比如插拔麦克风和耳机
  @param [OUT] deviceId 音频设备ID
  @param [OUT] deviceType 音频设备类型
  @param [OUT] deviceState 音频设备状态
  @remark 插拔麦克风或者耳机，会收到该通知
  */
  virtual void OnAudioDeviceStateChange(const char* deviceId, int deviceType, int deviceState) {}

  /**
  @brief 视频设备状态变化回调，比如插拔摄像头
  @param [OUT] deviceId 视频设备ID
  @param [OUT] deviceType 设备类型
  @param [OUT] deviceState 视频设备状态
  @remark 插拔摄像头，会收到该通知；注意deviceId和VideoDeviceInfo.index对应
  */
  virtual void onVideoDeviceStateChanged(const char* deviceId, MEDIA_DEVICE_TYPE deviceType, MEDIA_DEVICE_STATE_TYPE deviceState) {}

  /**
  @brief CDN推流结果通知
  @param [OUT] url 推流的URL
  @param [OUT] errorCode 推流的错误码
  @remark 用户调用addPublishOriginStreamUrl或addPublishTranscodingStreamUrl推流时，在状态发生变化时就会收到该通知
  */
  virtual void onPublishStreamToCDNStatus(const char* url, ThunderPublishCDNErrorCode errorCode) {}

  /**
  @brief 上下行流量通知 (周期性通知，每2秒通知一次)
  @param [OUT] stats 具体的状态
  @remark 用户进频道后，就会收到该通知
  */
  virtual void onRoomStats(RoomStats stats) {}

  /**
  @brief 业务自定义广播消息通知
  @param [OUT] uid 发送该消息的uid
  @param [OUT] msgData 接收到的自定义广播消息
  @remark 主播有通过sendUserAppMsgData发送数据，进频道的观众会收到该通知
  */
  virtual void onRecvUserAppMsgData(const char* uid, const char* msgData) {}
  
  /**
  @brief 业务发自定义广播消息发送失败通知
  @param [OUT] int 自定义广播消息发送失败的具体的原因 【参见ThunderSendAppMsgDataFailedStatus】
  @remark 主播调用sendUserAppMsgData发送数据失败时，就会收到该通知
  */
  virtual void onSendAppMsgDataFailedStatus(int status) {}

  /**
  @brief 摄像头采集状态变化通知
  @param [OUT] status 摄像头采集状态 【参见ThunderCaptureStatus】
  */
  virtual void onVideoCaptureStatus(int status) {}

  /**
  * 本地视频流的统计信息回调
  * 该回调描述本地设备发送视频流的统计信息，回调时机：1、调用开播接口立刻回调 2、开播中途切换档位立刻回调 3、2s间隔周期性回调
  * @param stats 本地视频统计数据，详细定义见 【参见LocalVideoStats】
  */
  virtual void onLocalVideoStats(const LocalVideoStats stats) {}

  /**
  * 本地音频流的统计信息回调
  * 该回调描述本地设备发送音频流的统计信息，回调时机：2s间隔周期性回调
  * @param stats 本地音频统计数据，详细定义见 【参见LocalAudioStats】
  */
  virtual void onLocalAudioStats(const LocalAudioStats stats) {}

  /**
  * 远端视频流的统计信息回调
  * 该回调描述远端用户在通话中端到端的视频流状态，针对每个远端用户/主播每 2 秒触发一次。如果远端同时存在多个用户/主播，该回调每 2 秒会被触发多次
  * @param uid 远端用户/主播id
  * @param stats 远端视频统计数据，详细定义见 【参见RemoteVideoStats】
  */
  virtual void onRemoteVideoStatsOfUid(const char* uid, const RemoteVideoStats stats) {}

  /**
  * 远端音频流的统计信息回调
  * 该回调描述远端用户在通话中端到端的音频流状态，针对每个远端用户/主播每 2 秒触发一次。如果远端同时存在多个用户/主播，该回调每 2 秒会被触发多次
  * @param uid 远端用户/主播id
  * @param stats 远端音频统计数据，详细定义见 【参见RemoteAudioStats】
  */
  virtual void onRemoteAudioStatsOfUid(const char* uid, const RemoteAudioStats stats) {}

  /**
  * 采集音量回调
  * @param totalVolume 上行音量能量值[0-100]
  * @param cpt 采集时间戳
  * @param micVolume 仅麦克风采集的音量能量值[0-100]
  * 默认关闭，开关：enableCaptureVolumeIndication
  */
  virtual void onCaptureVolumeIndication(int totalVolume, int cpt, int micVolume) {}

  /**
  * 远端用户音频状态回调
  * @param uid 用户uid
  * @param state 远端用户音频状态
  * @param reason 音频处于当前状态原因
  * @param elapsed 从进频道到发生改状态经历的时间
  */
  virtual void onRemoteAudioStateChangedOfUid(const char* uid,
	  REMOTE_AUDIO_STATE state,
	  REMOTE_AUDIO_REASON reason,
	  int elapsed) {}

  /**
  * 远端用户视频状态回调
  * @param uid 用户uid
  * @param state 远端用户视频状态
  * @param reason 远端用户状态改变的原因
  * @param elapsed 从进频道到远端用户发生状态改变经历的时间
  */
  virtual void onRemoteVideoStateChangedOfUid(const char* uid,
	  REMOTE_VIDEO_STATE state,
	  REMOTE_VIDEO_REASON reason,
	  int elapsed) {}

  /**
  * 已播放远端音频首帧回调
  * @param uid 远端用户uid
  * @param elapsed 从进频道到发生改状态经历的时间
  */
  virtual void onRemoteAudioPlay(const char* uid, int elapsed) {}

  /**
  * 本地视频流状态改变回调
  * @param status 本地视频流状态，详细定义见 LOCAL_VIDEO_STREAM_STATUS
  * @param error 本地视频流状态改变的原因，详细定义见 LOCAL_VIDEO_STREAM_ERROR_REASON
  */
  virtual void onLocalVideoStatusChanged(LOCAL_VIDEO_STREAM_STATUS status, LOCAL_VIDEO_STREAM_ERROR_REASON error) {}

  /**
  * CPU/内存使用情况
  *该回调加入房间后，每两秒钟回调一次
  * @param [OUT] stats CPU/内存使用信息，详见DeviceStats
  */
  virtual void onDeviceStats(const DeviceStats& stats) {}

  /**
  * 回放、录音设备或 App 的音量发生改变
  * 设备音量发生变化时回调
  * @param deviceType 设备类型，详见MEDIA_DEVICE_TYPE
  * @param volume 音量
  * @param muted 是否静音，0：不静音；1：静音
  */
  virtual void onAudioDeviceVolumeChanged(int deviceType, int volume, bool muted) {}

  /**
  * 本地音频状态发生变化
  * 本地音频系统状态发生改变时（包括本地麦克风录制状态和音频编码状态），SDK 会触发回调报告当前本地音频状态
  * @param status 本地音频状态，详见LOCAL_AUDIO_STREAM_STATUS
  * @param errorReason 错误码，当本地音频状态为THUNDER_LOCAL_AUDIO_STREAM_STATUS_FAILE，可通过状态码检索具体原因
  */
  virtual void onLocalAudioStatusChanged(LOCAL_AUDIO_STREAM_STATUS status, LOCAL_AUDIO_STREAM_ERROR_REASON errorReason) {}
};

class IAudioDeviceManager
{
 public:
  virtual ~IAudioDeviceManager() {}

 public:
  /**
  @brief 枚举音频输入设备
  @param [OUT] devices 音频设备信息
  @return 返回音频输入设备的数量
  @remark 需要"初始化"后才能调用
  */
  virtual int enumInputDevices(AudioDeviceList& devices) = 0;

  /**
  @brief 设置音频输入设备
  @param [IN] id 音频设备id
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后才能调用
  */
  virtual int setInputtingDevice(GUID& id) = 0;

  /**
  @brief 获取当前选择的输入设备
  @param [OUT] id 音频设备id
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后才能调用
  */
  virtual int getInputtingDevice(GUID& id) = 0;

  /**
  @brief 设置当前音频输入设备音量
  @param [IN] volume 要设置的音量值 [0-100]
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后才能调用
  */
  virtual int setInputtingVolume(int volume) = 0;

  /**
  @brief 获取当前音频输入设备音量
  @param [OUT] 当前音频输入设备音量 [0-100]
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后才能调用
  */
  virtual int getInputtingVolume(int& volume) = 0;

  /**
  @brief 开启或取消静音当前音频输入设备
  @param [IN] mute true:开启静音 false:取消静音
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后才能调用
  */
  virtual int setInputtingMute(bool mute) = 0;

  /**
  @brief 获取当前音频输入设备的静音状态
  @param [OUT] mute true:开启静音 false:取消静音
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后才能调用
  */
  virtual int getInputtingMute(bool& mute) = 0;

  /**
  @brief 启动当前音频输入设备测试
  @param [IN] indicationInterval 预留参数，建议填0
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后才能调用，调用后，会收到onInputVolume通知
  */
  virtual int startInputDeviceTest(int indicationInterval) = 0;

  /**
  @brief 停止当前音频输入设备测试
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后才能调用
  */
  virtual int stopInputDeviceTest() = 0;

  /**
  @brief 枚举音频播放设备
  @param [OUT] devices 音频播放设备
  @return 返回音频播放设备数量
  @remark 需要"初始化"后才能调用
  */
  virtual int enumOutputDevices(AudioDeviceList& devices) = 0;

  /**
  @brief 指定音频播放设备
  @param [IN] id 音频设备id
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后才能调用
  */
  virtual int setOutputtingDevice(GUID& id) = 0;

  /**
  @brief 获取当前音频播放设备
  @param [OUT] id 音频设备id
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后才能调用
  */
  virtual int getOutputtingDevice(GUID& id) = 0;

  /**
  @brief 设置当前播放设备音量
  @param [IN] volume 播放音量
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后才能调用
  */
  virtual int setOuttingVolume(int volume) = 0;

  /**
  获取当前播放设备音量
  @param [OUT] volume 播放音量
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后才能调用
  */
  virtual int getOuttingVolume(int& volume) = 0;

  /**
  @brief 开启/取消静音当前播放设备
  @param [IN] mute true:开启静音 false:取消静音
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后才能调用
  */
  virtual int setOutputtingMute(bool mute) = 0;

  /**
  @brief 获取当前播放设备的静音状态
  @param [OUT] mute true:开启静音 false:取消静音
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后才能调用
  */
  virtual int getOutputtingMute(bool& mute) = 0;

  /**
  @brief 启动当前播放设备测试
  @param [IN] indicationInterval 预留参数，建议填0
  @param [IN] audioFileName 播放的音频文件的全路径，win7及以上支持的格式:mp3,aac,wave；win7以下系统仅支持wav
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后才能调用
  */
  virtual int startOutputDeviceTest(int indicationInterval, const char* audioFileName) = 0;

  /**
  @brief 停止当前播放设备测试
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后才能调用
  */
  virtual int stopOutputDeviceTest() = 0;

  /**
  @brief 启动/关闭麦克风增强
  @param [IN] enabled true:启动麦克风增强；false:关闭麦克风增强；默认为false
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后调用，仅在destroyEngine时重置
  */
  virtual int enableMicEnhancement(bool enabled) = 0;

  /**
  @brief 启动/关闭麦克风降噪
  @param [IN] enabled true:启动麦克风降噪；false:关闭麦克风降噪；默认为false
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后调用，仅在destroyEngine时重置
  */
  virtual int enableMicDenoise(bool enabled) = 0;

  /**
  @brief 启动/关闭回声消除
  @param [IN] enabled true:启动回声消除；false:关闭回声消除；默认为false
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后调用，仅在destroyEngine时重置
  */
  virtual int enableAEC(bool enabled) = 0;

  /**
  @brief 启动/关闭自动增益功能[自动音量控制]
  @param [IN] enabled true:启动关闭自动增益功能；false:关闭自动增益功能；默认为false
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后调用，仅在destroyEngine时重置
  */
  virtual int enableAGC(bool enabled) = 0;
};

class IVideoDeviceManager
{
 public:
  virtual ~IVideoDeviceManager() {}

 public:
  /**
  @brief 枚举视频输入设备
  @param [OUT] devices 视频输入设备列表
  @return 返回视频输入设备的数量
  @remark 需要"初始化"后调用
  */
  virtual int enumVideoDevices(VideoDeviceList& devices) = 0;

  /**
  @brief 启动视频设备的采集
  @param [IN] deviceIdx 视频设备索引，需要使用enumVideoDevices中获取的值
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后调用
  */
  virtual int startVideoDeviceCapture(int deviceIdx) = 0;

  /**
  @brief 停止视频设备的采集
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后调用
  */
  virtual int stopVideoDeviceCapture() = 0;

  /**
  @brief 枚举监视器输入设备
  @param [OUT] devices 监视器设备列表
  @return 返回视频输入设备的数量
  @remark 需要"初始化"后调用
  */
  virtual int enumMonitorDevices(MonitorDeviceList& devices) = 0;
};

class IVideoCaptureObserver
{
 public:
  /**
  @brief 本地的采集视频数据的通知，目前数据格式为BGRA
  @remark 需要通过registerVideoCaptureObserver进行注册
  */
  virtual bool onCaptureVideoFrame(VideoFrame& videoFrame) = 0;
};

class IVideoFrameObserver
{
 public:
  virtual ~IVideoFrameObserver() {}

 public:
  /**
  @brief 本地的预览视频数据的通知，目前数据格式为YUV420
  @remark 需要通过registerVideoFrameObserver进行注册
  */
  virtual bool onPreviewVideoFrame(VideoFrame& videoFrame) = 0;

  /**
  @brief 其他用户的渲染视频数据的通知，数据格式为YUV420
  @remark 需要通过registerVideoFrameObserver进行注册
  */
  virtual bool onRenderVideoFrame(const char* uid, VideoFrame& videoFrame) = 0;
};

class IThunderMediaExtraInfoObserver
{
 public:
  enum ThunderSendMediaExtraInfoFailedStatus
  {
    THUNDER_SEND_MEDIA_EXTRA_INFO_FAILED_DATA_EMPTY = 1, // 次要信息为空
    THUNDER_SEND_MEDIA_EXTRA_INFO_FAILED_DATA_TOO_LARGE = 2, // 每次发送数据太大
    THUNDER_SEND_MEDIA_EXTRA_INFO_FAILED_FREQUENCY_TOO_HIGHT = 3, // 发送频率太高
    THUNDER_SEND_MEDIA_EXTRA_INFO_FAILED_NOT_IN_ANCHOR_SYSTEM = 4, // 不是主播系统
    THUNDER_SEND_MEDIA_EXTRA_INFO_FAILED_NO_JOIN_MEDIA = 5, // 未进频道
    THUNDER_SEND_MEDIA_EXTRA_INFO_FAILED_NO_PUBLISH_SUCCESS = 6, // 未成功开播
  };

  struct MixAudioInfo // 混音流信息
  {
    char uid[MAX_THUNDER_UID_LEN]; // 用户id
    int volume;    // 混音流音量 [0,100]
  };

  struct MixAudioInfoList // 混音流信息列表
  {
    int count; // 混音流信息列表个数
    MixAudioInfo mixAudio[MAX_THUNDER_MIX_AUDIO_COUNT]; // 具体的混音流信息
  };

  struct MixVideoInfo
  {
    char uid[MAX_THUNDER_UID_LEN]; // 用户id
    int width; // 此用户视频原始宽
    int height; // 此用户视频原始高
    int cropX; // 混画时裁剪原始视频的起始x坐标
    int cropY; // 混画时裁剪原始视频的起始y坐标
    int cropW; // 混画时裁剪原始视频的宽
    int cropH; // 混画时裁剪原始视频的高
    int layoutX; // 此用户视频在混画画布中的起始x坐标
    int layoutY; // 此用户视频在混画画布中的起始y坐标
    int layoutW; // 此用户视频在混画画布中的宽度
    int layoutH; // 此用户视频在混画画布中的高度
    int zOrder; // 此用户视频帧在混画中的图层编号，取值范围为 [0, 100] 中的整型，最小值为 0，表示该区域图像位于最下层
    float alpha; // 此用户视频帧在混画中的透明度。
                 // 取值范围为 [0.0, 1.0]。0.0 表示该区域图像完全透明，而 1.0 表示该区域图像完全不透明
  };

  struct MixVideoInfoList // 混画流信息列表
  {
    int count; // 混画流信息列表个数
    MixVideoInfo mixVideo[MAX_THUNDER_MIX_VIDEO_COUNT]; // 具体的混画流信息
  };

  /**
  @brief 发送媒体次要信息失败状态通知
  @param [OUT] 失败错误码 具体值参见：ThunderSendMediaExtraInfoFailedStatus
  */
  virtual void onSendMediaExtraInfoFailedStatus(int status) = 0;

  /**
  @brief 接收到的媒体次要信息
  @param [OUT] uid 用户id
  @param [OUT] pData 媒体次要信息
  @param [OUT] dataLen 媒体次要信息长度
  */
  virtual void onRecvMediaExtraInfo(const char* uid, const char* pData, int dataLen) = 0;

  /**
  @brief 接收到的混音流的次要信息
  @param [OUT] uid 用户id
  @param [OUT] infos 混音流信息列表
  */
  virtual bool onRecvMixAudioInfo(const char* uid, MixAudioInfoList& infos) = 0;

  /**
  @brief 接收到的混画流的次要信息
  @param [OUT] uid 用户id
  @param [OUT] infos 混画流信息列表
  */
  virtual bool onRecvMixVideoInfo(const char* uid, MixVideoInfoList& infos) = 0;
};

class IThunderAudioPlayerNotify
{
 public:
  virtual ~IThunderAudioPlayerNotify() {}

  /**
  @brief 该接口已经废除，不再起作用
  */
  virtual void onAudioFilePlayEnd() {}

  /**
  @brief 播放事件的各种状态
  @param [OUT] event 描述播放事件
  event = 0:NONE
  event = 1:打开文件
  event = 2:开始播放
  event = 3:停止播放
  event = 4:暂停播放
  event = 5:恢复播放
  event = 6:播放完毕
  event = 7:播放快进
  @param [OUT] errorCode,错误码描述.
  errorCode = 0:  成功
  errorCode = -1: 文件格式解析出错
  errorCode = -2: 文件格式解码出错
  errorCode = -3: 文件格式不支持
  errorCode = -4: 文件路径不存在
  */
  virtual void onAudioFileStateChange(ThunderAudioFilePlayerEvent event, ThunderAudioFilePLayerErrorCode errorCode) {}

  /**
  @brief 播放音量信息
  @param [OUT] volume 音量大小
  @param [OUT] currentMs 当时文件时长
  @param [OUT] totalMs 文件总时长
  */
  virtual void onAudioFileVolume(unsigned int volume, unsigned int currentMs, unsigned int totalMs) {}
};

class IThunderAudioPlayer
{
 public:
  virtual ~IThunderAudioPlayer() {}

 public:
  /**
  @brief 打开伴奏文件
  @param [IN] path 文件路径
  @param [OUT] 打开成功
  */
  virtual bool open(const char* path) = 0;

  /**
  @brief 关掉伴奏
  */
  virtual void close() = 0;

  /**
  @brief 开始播放
  */
  virtual void play() = 0;

  /**
  @brief 停止播放
  */
  virtual void stop() = 0;

  /**
  @brief 暂停
  */
  virtual void pause() = 0;

  /**
  @brief 恢复
  */
  virtual void resume() = 0;

  /**
  @brief 跳到指定时间播放
  @param [IN] timeMS 指定时间
  */
  virtual void seek(unsigned int timeMS) = 0;

  /**
  @brief 获取文件时长
  */
  virtual unsigned int getTotalPlayTimeMS() = 0;

  /**
  @brief 获取文件当前播放时间
  */
  virtual unsigned int getCurrentPlayTimeMS() = 0;

  /**
  @brief deprecated
  */
  virtual void setPlayVolume(int volume) = 0;

  /**
  @brief 设置文件本地播放音量
  */
  virtual int setPlayerLocalVolume(int volume) = 0;

  /**
  @brief 设置文件远端播放音量
  */
  virtual int setPlayerPublishVolume(int volume) = 0;

  /**
  @brief 获取文件本地播放音量
  */
  virtual int getPlayerLocalVolume() = 0;

  /**
  @brief 获取文件远端播放音量
  */
  virtual int getPlayerPublishVolume() = 0;

  /**
  @brief  deprecated，【该接口从2.6.0开始已废弃】，获取音轨数
  */
  virtual int getAudioTrackCount() = 0;

  /**
  @brief deprecated，【该接口从2.6.0开始已废弃】，选择音轨
  */
  virtual int selectAudioTrack(int audioTrack) = 0;

  /**
  @brief 设置音频播放的声调
  @param [IN] val 声调值 -5, -4, -3, -2, -1, 0(normal), 1, 2, 3, 4, 5
  */
  virtual void setSemitone(int val) = 0;

  /**
  @brief 设置音频播放速率
  @param [IN] val 速率值 0.5，0.75， 1.0， 1.25，1.5，1.75，2.0
  */
  virtual void setTempo(float val) = 0;

  /**
  @brief 设置音频播放方位
  @param [IN] azimuth -90~90
  */
  virtual void setPosition(int azimuth) = 0;

  /**
  @brief 设置播放循环次数
  */
  virtual int setLooping(int cycle) = 0;

  /**
  @brief deprecated，【该接口从2.6.0开始已废弃】，伴奏开播
  */
  virtual void enablePublish(bool enable) = 0;

  /**
  @brief deprecated，该接口已废弃，请使用 setPlayerEventCallback 接口
  @brief 设置文件回调
  */
  virtual void SetFilePlayerNotify(IThunderAudioPlayerNotify* notify) = 0;

  /*
  @brief 设置文件播放回调
  */
  virtual void setPlayerEventCallback(IThunderAudioPlayerNotify* notify) = 0;
};

class IThunderEngine
{
 public:
  /**
  @brief 销毁IThunderEngine对象
  @remark 需要"初始化"后才能调用
  */
  virtual void destroyEngine() = 0;

  /**
  @brief 初始化IThunderEngine对象
  @param [IN] appId 为应用程序开发者签发的 AppID
  @param [IN] sceneId 开发者自定义场景Id，用以细分业务场景；如果不需要，可以建议填0
  @param [IN] pHandler 通知处理接口，不能为NULL
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"创建实例"后调用，仅在destroyEngine时重置
  */
  virtual int initialize(const char* appId, int sceneId, IThunderEventHandler* pHandler) = 0;

  /**
  @brief 设置用户国家区域
  @param [IN] area 区域类型（默认值：AREA_DEFAULT（国内））
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark joinRoom前调用生效。国外用户必须调用，国内用户可以不调用
  */
  virtual int setArea(AREA_TYPE area) = 0;

  /**
  @brief 设置是否支持字符串UID
  @param [IN] useStringUid 默认值:true
    true:字符串uid，支持[A,Z],[a,z],[0,9],-,_等字符的排列组合，且长度不能超过64个字节
    false:使用32位无符号整型，只支持[0-9]，最大值4294967295
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后并在joinRoom前调用，会在destroyEngine时重置，属于非公开接口（如非必要不建议使用）
  */
  virtual int setUse64bitUid(bool useStringUid) = 0;

  /**
  @brief 进入房间
  @param [IN] token 鉴权所需，详见官网的"用户鉴权说明"
  @param [IN] tokenLen 标记token长度
  @param [IN] roomId  房间Id（AppId下唯一）
  @param [IN] uid 用户id, 只支持[A,Z],[a,z],[0,9],-,_等字符的排列组合，且长度不能超过64个字节
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后才能调用
  注1：SDK版本2.2及之前的用户，如果需要使用无符号32位uid，需要调用接口setUse64bitUid(false)
  注2：函数返回成功仅表示请求执行成功，加入房间成功的标志是收到onJoinRoomSuccess通知
  */
  virtual int joinRoom(const char* token, int tokenLen, const char* roomId, const char* uid) = 0;

  /**
  @brief 离开房间
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要在joinRoom成功返回后才可调用
  */
  virtual int leaveRoom() = 0;

  /**
  @brief 更新token
  @param [IN] token 鉴权所需，详见官网的"用户鉴权说明"
  @param [IN] tokenLen 标记token长度
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后才能调用
  */
  virtual int updateToken(const char* token, int tokenLen) = 0;

  /**
  @brief 设置媒体模式
  @param [IN] mode 媒体模式
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后、"进入房间"前调用，仅在destroyEngine被重置
  */
  virtual int setMediaMode(THUNDER_PROFILE mode) = 0;

  /**
  @brief 设置房间模式
  @param [IN] mode 房间模式
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后，仅在destroyEngine被重置
  */
  virtual int setRoomMode(ROOM_CONFIG_TYPE mode) = 0;

  /**
  @brief 设置房间模式
  @deprecated 【该接口已废弃】使用新接口：setMediaMode与setRoomMode代替
  @param [IN] profile 媒体模式
  @param [IN] roomConfig 房间模式
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后、"进入房间"前调用
  */
  virtual int setRoomConfig(THUNDER_PROFILE profile, ROOM_CONFIG_TYPE roomConfig) = 0;

  /**
  @brief 音频开播
  @deprecated 【该接口已废弃】建议使用stopLocalAudioStream(false);
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需"进房间成功"后才能调用
  */
  virtual int enableAudioEngine() = 0;

  /**
  @brief 音频停播
  @deprecated 【该接口已废弃】建议使用stopLocalAudioStream(true);
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需"进房间成功"后才能调用
  */
  virtual int disableAudioEngine() = 0;

  /**
  @brief 设置音频模式
  @param [IN] profile 音频类型
  @param [IN] commutMode 交互模式
  @param [IN] scenarioMode 情景模式
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后、音频采集开播前调用
  */
  virtual int setAudioConfig(AUDIO_PROFILE_TYPE profile, COMMUT_MODE commutMode, SCENARIO_MODE scenarioMode) = 0;

  /**
  @brief 设置开播模式
  */
  virtual int setAudioSourceType(ThunderSourceType sourceType) = 0;

  /**
  @brief 关闭/打开本地音频(包括音频的采集编码与上行)
  @param [IN] stop true：关闭本地音频； false：打开本地音频
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需"进房间成功"才能调用
  */
  virtual int stopLocalAudioStream(bool stop) = 0;

  /**
  @brief 停止/接收所有音频数据，默认是false
  @param [IN] stop true:停止所有远端音频 false:接收所有远端音频
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用，仅在destroyEngine时重置
  判断是否接收或禁止远端用户，优先判断stopRemoteAudioStream设置的值，没有再使用该函数设置的值
  每次调用stopAllRemoteAudioStreams都会清掉stopRemoteAudioStream单个设置项。
  */
  virtual int stopAllRemoteAudioStreams(bool stop) = 0;

  /**
  @brief 停止/接收指定音频数据
  @param [IN] uid 用户id
  @param [IN] stop true:停止用户音频 false:接收用户音频
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用，仅在destroyEngine时重置
  判断是否接收或禁止远端用户，优先判断该设置的值，没有再使用stopAllRemoteAudioStreams设置的值
  */
  virtual int stopRemoteAudioStream(const char* uid, bool stop) = 0;

  /**
  @brief 设置远程某个用户在本地的播放音量
  @param [IN] uid 用户id
  @param [IN] volume 音量[0--100]
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用，仅在destroyEngine时重置
  */
  virtual int setPlayVolume(const char* uid, int volume) = 0;

  /**
  @brief 启用说话者音量提示
  @param [IN] interval <=0:禁用音量提示功能; >0 返回音量提示的间隔,单位毫秒,建议大于200毫秒
  @param [IN] smooth 预留参数，暂未实现
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用，仅在destroyEngine时重置；启用后，房间内有人说话会收到onPlayVolumeIndication通知
  */
  virtual int setAudioVolumeIndication(int interval, int smooth) = 0;

  /**
  @brief 打开采集音量回调
  @param [IN] interval <=0: 禁用音量提示功能 >0: 回调间隔，单位为毫秒
  @param [IN] moreThanThd 从<moreThanThd到>=moreThanThd，立即回调一次 <=0无效
  @param [IN] lessThanThd 从>=lessThanThd到<lessThanThd，立即回调一次 <=0无效
  @param smooth 未实现
  @return 0:成功, 其它错误参见enum ThunderRet
  */
  virtual int enableCaptureVolumeIndication(int interval, int moreThanThd, int lessThanThd, int smooth) = 0;

  /**
  @brief 开启/关闭声卡采集
  @param [IN] enabled true:开始声卡采集 false:关闭声卡采集
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用，仅在destroyEngine时停止
  */
  virtual int enableLoopbackRecording(bool enabled) = 0;

  /**
  @brief 开始录制
  @param [IN] fileName 录制文件名（完整路径、不包含扩展名，扩展名根据fileType生成）
  @param [IN] fileType 文件格式
  @param [IN] quality 录制质量
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用
  */
  virtual int startAudioRecording(const char* fileName,
                                  AUDIO_RECORDING_FILE_TYPE fileType,
                                  AUDIO_RECORDING_QUALITY_TYPE quality) = 0;

  /**
  @brief 停止录制
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用
  */
  virtual int stopAudioRecording() = 0;

  /**
  @brief 设置麦克风音量
  @param [IN] volume 取值范围[0--400]
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用
  */
  virtual int adjustRecordingSignalVolume(int volume) = 0;

  /**
  @brief 设置播放音量
  @param [IN] volume 取值范围[0--400]
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用
  */
  virtual int adjustPlaybackSignalVolume(int volume) = 0;

  /**
  @brief 获取音频设备管理接口的实例对象
  @return 音频设备管理接口的对象指针或者NULL
  @remark 需在"初始化"后调用
  */
  virtual IAudioDeviceManager* getAudioDeviceMgr() = 0;

  /*!
  @brief 注册音频帧观测器
  @param observer 音频观测器对象
  @remark 用户需继承IAudioFrameObserver接口类 并复写其中的四个方法，相应的音频原始数据将从这些方法中传给用户
  */
  virtual bool registerAudioFrameObserver(IAudioFrameObserver *observer) = 0;

  /**
  @brief 设置onRecordAudioFrame回调中 音频录制原始数据使用模式
  @param [IN] sampleRate 采样率
  @param [IN] channel    声道；1:单声道，2：双声道
  @param [IN] mode  onRecordAudioFrame 的使用模式，详见 ThunderAudioRawFrameOperationMode
  @param [IN] samplesPerCall 指定 onRecordAudioFrame 中返回数据的采样点数，如转码推流应用中通常为 1024。
  samplesPerCall = (int)(sampleRate × sampleInterval)，其中：sampleInterval ≥ 0.01，单位为秒。
  @return 0:成功, 其它错误参见enum ThunderRet
  */
  virtual int setRecordingAudioFrameParameters(int sampleRate,
	  int channel,
	  ThunderAudioRawFrameOperationMode mode,
	  int samplesPerCall) = 0;

  /**
  设置onPlaybackAudioFrame回调中 音频播放的原始数据使用模式
  @param [IN] sampleRate 采样率
  @param [IN] channel    声道；1:单声道，2：双声道
  @param [IN] mode      onPlaybackAudioFrame 的使用模式，详见 ThunderAudioRawFrameOperationMode
  @param [IN] samplesPerCall 指定 onPlaybackAudioFrame 中返回数据的采样点数，如转码推流应用中通常为 1024。
  samplesPerCall = (int)(sampleRate × sampleInterval)，其中：sampleInterval ≥ 0.01，单位为秒。
  @return 0:成功, 其它错误参见enum ThunderRet
  */
  virtual int setPlaybackAudioFrameParameters(int sampleRate,
	  int channel,
	  ThunderAudioRawFrameOperationMode mode,
	  int samplesPerCall) = 0;

  /**
  @brief 设置SDK输出log文件的目录。必须指定一个有写入权限的目录。
  @param [IN] filePath 完整的日志文件目录
  @return 0:成功, 其它错误参见enum ThunderRet
  */
  virtual int setLogFilePath(const char* filePath) = 0;

  /**
  @brief 设置日志保存等级
  @param [IN] filter 日志过滤器
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 将过滤掉等级（LogLevel）较低的日志，只有日志等级（LogLevel）等于和高于该数值的日志会被记录。
  */
  virtual int setLogLevel(LOG_FILTER filter) = 0;

  /**
  @brief 注册视频观测器对象
  @param [IN] observer 对象实例。如果observer等于NULL，则取消注册
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用
  */
  virtual int registerVideoFrameObserver(IVideoFrameObserver* observer) = 0;

  /**
  @brief 获取视频设备管理接口的实例对象
  @return 视频设备管理接口对象指针指针或者NULL
  @remark 需在"初始化"后调用
  */
  virtual IVideoDeviceManager* getVideoDeviceMgr() = 0;

  /**
  @brief 启用视频模块
  @deprecated 【该接口已废弃】在PROFILE_NORMAL模式下，视频模块默认可用
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用
  */
  virtual int enableVideoEngine() = 0;

  /**
  @brief 关闭视频模块
  @deprecated 【该接口已废弃】如果不需要视频模块可通过setMediaMode(PROFILE_ONLY_AUDIO)设置
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用
  */
  virtual int disableVideoEngine() = 0;

  /**
  @brief 设置视频编码配置
  @param [IN] config 具体的编码配置
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用
  */
  virtual int setVideoEncoderConfig(const VideoEncoderConfiguration& config) = 0;

  /**
  @brief 根据视频编码配置获取编码参数
  @param [IN] configIn 具体的编码配置
  param [OUT] paramOut 具体的编码参数
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用
  */
  virtual int getVideoEncoderParam(const VideoEncoderConfiguration& configIn, ThunderVideoEncodeParam& paramOut) = 0;

  /**
  @brief 设置本地视频的渲染视图
  @param [IN] canvas 具体的渲染设置
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用
  */
  virtual int setLocalVideoCanvas(const VideoCanvas& canvas) = 0;

  /**
  @brief 设置远端视频的渲染视图
  @param [IN] canvas 具体的视图设置
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用
  */
  virtual int setRemoteVideoCanvas(const VideoCanvas& canvas) = 0;

  /**
  @brief 设置本地视图显示模式
  @param [IN] mode 渲染显示模式
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用
  */
  virtual int setLocalCanvasScaleMode(VideoRenderMode mode) = 0;

  /**
  @brief 设置远端视图显示模式
  @param [IN] mode 渲染显示模式
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用
  */
  virtual int setRemoteCanvasScaleMode(VideoRenderMode mode) = 0;

  /**
  @brief 开启视频预览
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用
  */
  virtual int startVideoPreview() = 0;

  /**
  @brief 停止视频预览
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用
  */
  virtual int stopVideoPreview() = 0;

  /**
  @brief 打开/关闭本地视频采集
  @param [IN] enabled true:打开本地采集 false:关闭本地采集
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用
  */
  virtual int enableLocalVideoCapture(bool enabled) = 0;

  /**
  @brief 打开/关闭本地视频发送
  @param [IN] stop true:打开本地视频发送 false:关闭本地视频发送
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用
  */
  virtual int stopLocalVideoStream(bool stop) = 0;

  /**
  @brief 停止/接收指定的远端视频
  @param [IN] uid 用户id
  @param [IN] stop true:禁止指定用户远端视频，false:接收指定用户远端视频
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用，仅在destroyEngine时重置
  判断是否接收或禁止远端用户，优先判断该设置的值，没有的话再使用stopAllRemoteVideoStreams设置的值
  */
  virtual int stopRemoteVideoStream(const char* uid, bool stop) = 0;

  /**
  @brief 停止／接收所有远端视频
  @param [IN] stop true:禁止所有远端视频流，false:接收所有远端视频流，默认值为:false
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用，仅在destroyEngine时重置
  判断是否接收或禁止远端用户，优先判断stopRemoteVideoStream设置的值，没有的话再使用该函数设置的值
  每次调用stopAllRemoteVideoStreams都会清掉stopRemoteVideoStream单个设置项。
  */
  virtual int stopAllRemoteVideoStreams(bool stop) = 0;

  /**
  @brief 设置本地视频水印
  @param [IN] watermark 水印图片信息，该接口的URL仅支持本地绝对路径;
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用，当前只支持一个水印，后添加的水印会替换掉之前添加的水印
          只支持24位和32位的图片文件；SDK会对图片按设置的宽度进行转换
  */
  virtual int setVideoWatermark(const ThunderBoltImage& watermark) = 0;

  /**
  @brief 清除本地视频水印
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 该方法清除setVideoWatermark设置的水印
  */
  virtual int removeVideoWatermarks() = 0;

  /**
  @brief 设置外部音频采集参数
  @param [IN] bEnable 是否启动音频采集
  @param [IN] option 外部音频采集参数
  @return 0:成功, 其它错误参见enum ThunderRet
  */
  virtual int setCustomAudioSource(bool bEnable, CustomAudioOptions& option) = 0;

  /**
  @brief 推送外部音频帧
  @param [IN] pData PCM音频帧数据
  @param [IN] dataLen 数据长度
  @param [IN] timeStamp 采集时间戳
  @return 0:成功, 其它错误参见enum ThunderRet
  */
  virtual int pushCustomAudioFrame(const char* pData, unsigned dataLen, unsigned timeStamp) = 0;

  /**
  @brief 设置外部视频采集参数
  @param [IN] bEnable 是否启动外部视频
  @param [IN] option 外部视频采集参数
  @return 0:成功, 其它错误参见enum ThunderRet
  */
  virtual int setCustomVideoSource(bool bEnable, CustomVideoOptions& option) = 0;

  /**
  @brief 推送外部视频帧
  @param [IN] yuv YUV数据
  @param [IN] linesize YUV数据中的缓冲区的行宽度
  @param [IN] timestamp 采集时间戳
  @return 0:成功, 其它错误参见enum ThunderRet
  */
  virtual int pushCustomVideoFrame(const unsigned char* yuv[3], int linesize[3], unsigned timestamp) = 0;

  /**
  @brief 添加源流推流地址 【最多支持5个推流地址】
  @param [IN] url 推流地址，格式为RTMP，不支持中文等特殊字符
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 开播之后会服务器会将源流推到对应的URL上，需要进房间（joinRoom）后才能调用，退出房间会清空该配置
  */
  virtual int addPublishOriginStreamUrl(const char* url) = 0;

  /**
  @brief 删除源流推流地址
  @param [IN] url 要删除的推流地址
  @return 0:成功, 其它错误参见enum ThunderRet
  */
  virtual int removePublishOriginStreamUrl(const char* url) = 0;

  /**
  @brief 添加/更新转码任务 【同一房间最大支持5个转码任务】
  @param [IN] taskId 转码任务标识，由业务管理，保证房间内唯一，
                     只支持[A,Z],[a,z],[0,9],-,_，等字符的排列组合，且长度不能超过20个字节
  @param [IN] transcodingCfg 具体的转码布局
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 开播之后服务器会按设置的画布进行转码并推流(如有设置)，需要进房间（joinRoom）后才能调用，退出房间会清空该配置
  */
  virtual int setLiveTranscodingTask(const char* taskId, const LiveTranscoding& transcodingCfg) = 0;

  /**
  @brief 删除转码任务
  @param [IN] taskId 转码任务标识
  @return 0:成功, 其它错误参见enum ThunderRet
  */
  virtual int removeLiveTranscodingTask(const char* taskId) = 0;

  /**
  @brief 添加转码流的推流地址 【同一转码任务最多支持5个推流地址】
  @param [IN] taskId 转码任务标识
  @param [IN] url 推流地址，格式为RTMP，不支持中文等特殊字符
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要进房间（joinRoom）后才能调用，退出房间会清空该配置
  */
  virtual int addPublishTranscodingStreamUrl(const char* taskId, const char* url) = 0;

  /**
  @brief 删除转码流的推流地址
  @param [IN] taskId 转码任务标识
  @param [IN] url 要删除的推流地址
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要进房间（joinRoom）后才能调用
  */
  virtual int removePublishTranscodingStreamUrl(const char* taskId, const char* url) = 0;

  /**
  @brief 订阅指定的流【跨房间订阅】
  @param [IN] roomId 房间号【只支持[A,Z],[a,z],[0,9],-,_，等字符的排列组合，且长度不能超过64个字节】
  @param [IN] uid 用户id
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要进房间后才能调用，退出房间会清空该配置
  */
  virtual int addSubscribe(const char* roomId, const char* uid) = 0;

  /**
  @brief 取消流的订阅
  @param [IN] roomId 房间号【只支持[A,Z],[a,z],[0,9],-,_，等字符的排列组合，且长度不能超过64个字节】
  @param [IN] uid 用户id
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要进房间后才能调用
  */
  virtual int removeSubscribe(const char* roomId, const char* uid) = 0;

  /**
  @brief 打开/关闭WebSDK兼容
  @param [IN] enabled 是否开启兼容，默认关闭
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需在"初始化"后调用，仅在destroyEngine时重置
  */
  virtual int enableWebSdkCompatibility(bool enabled) = 0;

  /**
  @brief 设置Thunder的相关属性
  @param [IN] options 以JSON定义的相关配置信息
  1.设置视频群组订阅："JoinWithSubscribeGroup":true
  2.设置视频群组开播："PublishAudioToGroup":true
  3.设置频道号与子频道号: "setSid":79804098,"setSubsid":79804098
  "setSubsid":79804098,
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 需要"初始化"后并在joinRoom前调用，会在destroyEngine时重置，属于非公开接口（如非必要不建议使用）
  */
  virtual int setParameters(const char* options) = 0;

  /**
  @brief 获取当前网络连接状态
  @return 连接状态，参见enum ThunderConnectionStatus
  @remark 需在"初始化"后调用
  */
  virtual ThunderConnectionStatus getConnectionStatus() = 0;

  /**
  @brief 发送业务自定义广播消息
  @param [IN] msgData 业务自定义广播消息
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 该接口通过媒体UDP通道发送消息，具有低延时和不可靠的特性。具体约束如下：
  1.发送者必须进入房间。
  2.开麦成功后才能调用(纯观众和开播鉴权失败都不能发)。
  3.调用该接口的频率每秒不能超过2次,msgData的大小不能超过200字节
  4.不满足以上任一条件msg都会被丢弃。
  5.不保证一定送达房间内所有在线用户，不保证一定按序送达。
  注1:通过onSendAppMsgDataFailedStatus通知发送自定义广播消息失败的原因
  注2:其他用户发来的自定义广播消息，通过onRecvUserAppMsgData通知给应用程序
  */
  virtual int sendUserAppMsgData(const char* msgData) = 0;

  /**
  @brief 发送媒体次要信息（在音视频开播的情况下）
  @param [IN] extraData 媒体次要信息
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 发送媒体次要信息具体使用说明如下：
  1.发送者必须进入房间，音频开播成功之后调用
  2.只有音频开播：该接口调用频率最快为100ms一次; 媒体次要信息大小不超过200字节
  3.视频开播：调用频率不能超过帧率；次要信息不超过2048字节。
    例如：推流采用默认帧率15fps，即调用频率不能超过1000/15=66.7 ms/次
  4.可能存在丢包情况，
  5.SDK尽可能保证以在播放对应帧的时间点进行回调媒体数据
  注1:通过onSendMediaExtraInfoFailedStatus通知发送媒体次要信息失败的原因
  注2:其他用户发来的媒体次要信息，通过onRecvMediaExtraInfo通知给应用程序
  */
  virtual int sendMediaExtraInfo(const char* extraData) = 0;

  /**
  @brief 开启混画带媒体次要信息
  @param [IN] enabled true:开启混画带媒体次要信息；false:关闭混画带媒体次要信息；默认为false
  */
  virtual int enableMixVideoExtraInfo(bool enabled) = 0;

  /**
  @brief 设置本地视频镜像模式
  @param [IN] mode 镜像模式
  @return 0:成功, 其它错误参见enum ThunderRet
  @remark 可以分别设置本地预览和对方看到的视频的镜像模式，立即生效
  */
  virtual int setLocalVideoMirrorMode(ThunderVideoMirrorMode mode) = 0;

  /**
  @brief 开始捕捉指定窗口
  @param [IN] hWnd 窗口句柄
  @param [IN] pRect 指定捕捉窗口的子区域, 坐标为该窗口的相对坐标. 为NULL时捕捉整个窗口
  @return 0:成功, 其它错误参见enum ThunderRet
  */
  virtual int startScreenCaptureForHwnd(HWND hWnd, const RECT* pRect) = 0;

  /**
  @brief 开始捕捉指定桌面指定区域
  @param [IN] screenId 显示器ID
  @param [IN] pRect 指定捕捉的子区域, 坐标为指定显示器的相对坐标. 为NULL时捕捉整个显示器区域
  @return 0:成功, 其它错误参见enum ThunderRet
  */
  virtual int startScreenCaptureForScreen(int screenId, const RECT* pRect) = 0;

  /**
  @brief 更新捕捉的显示区域
  @param [IN] pRect 指定捕捉的子区域, 坐标为指定显示器或窗口的相对坐标. 为NULL时捕捉整个显示器或窗口区域
  @return 0:成功, 其它错误参见enum ThunderRet
  */
  virtual int updateScreenCaptureRect(const RECT* pRect) = 0;

  /**
  @brief 停止捕捉桌面或窗口
  @return 0:成功, 其它错误参见enum ThunderRet
  */
  virtual int stopScreenCapture() = 0;

  /**
  @brief 暂停捕捉桌面或窗口
  @return 0:成功, 其它错误参见enum ThunderRet
  */
  virtual int pauseScreenCapture() = 0;

  /**
  @brief 恢复捕捉桌面或窗口
  @return 0:成功, 其它错误参见enum ThunderRet
  */
  virtual int resumeScreenCapture() = 0;

  /**
  * @brief 是否支持某种Feature
  * 如：FEATURE_SUPPORT_MAGAPI 查询是否支持 Magnification API捕捉。
  */
  virtual bool checkFeatureSupport(FEATURE_SUPPORT flag) = 0;

  /**
  * @brief	设置屏幕捕捉时需要排除的窗口列表
  * @param	[in] wndList 捕捉时需排除的窗口列表
  * @param	[in] count 捕捉时需排除的窗口的个数
  */
  virtual int setCaptureExcludeWindowList(HWND* wndList, int count) = 0;

  /**
  @brief 注册摄像头采集数据观测器对象
  @param [IN] observer 对象实例, 如果observer等于NULL, 则取消注册
  @return 0:成功, 其它错误参见enum ThunderRet
  */
  virtual int registerVideoCaptureObserver(IVideoCaptureObserver* observer) = 0;

  /**
  @brief 注册媒体次要信息的观测器对象
  @param [IN] observer 对象实例, 如果observer等于NULL, 则取消注册
  @return 0:成功, 其它错误参见enum ThunderRet
  */
  virtual int registerMediaExtraInfoObserver(IThunderMediaExtraInfoObserver* observer) = 0;

  /**
  @brief 创建音频播放器
  @return 0:音频播放器对象
  */
  virtual IThunderAudioPlayer* createThunderAudioPlayer() = 0;

  /**
  @brief 销毁音频播放器
  */
  virtual void destroyThunderAudioPlayer(IThunderAudioPlayer* player) = 0;
  
 protected:
  IThunderEngine() {}
  virtual ~IThunderEngine() {}
};
} // namespace Thunder

EXTERN_C { THUNDER_ENGINE Thunder::IThunderEngine* createEngine(); };

#endif

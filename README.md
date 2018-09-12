###### iOS OC语言原生开发的IM模块，用于项目中需要原生开发IM的情况，具备发送文字、表情、语音、图片、视频等完整功能，包含图片预览视频播放等功能，此项目将会长期更新如有问题可以提出，我的邮箱：fshmjl@aliyun.com，我将尽快解决

###### 效果图如下
![image](https://github.com/fshmjl/RChat/blob/master/RChat/Messages/Resource/previewPicture.jpeg?raw=true)

##### 项目介绍
###### 项目中对输入框等模块功能进行了封装，方便复用或重写
    输入框模块              InputBox
    输入框功能页面           KInputBoxView.m
    输入框表情页面           KInputBoxViewCtrl.m
    输入框更多页面           KInputBoxMoreView.m
    输入框部分代理           KInputBoxViewDelegate

###### KInputBoxViewDelegate提供的代理

```

@protocol KInputBoxViewDelegate <NSObject>

@optional
#pragma mark - 表情页面（KInputBoxEmojiView）代理

/**
点击选择表情

@param emojiView 表情所在页面
@param emojiDic 表情数据
@param emojiType 表情类型
*/
- (void)emojiView:(KInputBoxEmojiView *)emojiView
didSelectEmoji:(KEmojiModel *)emojiDic
emojiType:(KEmojiType)emojiType;


/**
删除光标前面的表情
*/
- (void)emojiViewDeleteEmoji;

/**
点击发送按钮，发送表情

@param emojiView 表情菜单
@param emojiStr 发送按钮
*/
- (void)emojiView:(KInputBoxEmojiView *)emojiView
sendEmoji:(NSString *)emojiStr;

#pragma mark - 表情菜单代理部分

/**
点击添加表情按钮

@param menuView 表情菜单
@param addBut 点击按钮
*/
- (void)emojiMenuView:(KInputBoxEmojiMenuView *)menuView
clickAddAction:(UIButton *)addBut;

/**
选择表情组

@param menuView 表情菜单页面
@param emojiGroup 表情组
*/
- (void)emojiMenuView:(KInputBoxEmojiMenuView *)menuView
didSelectEmojiGroup:(KEmojiGroup *)emojiGroup;

/**
点击发送按钮，发送表情

@param menuView 表情菜单
@param sendBut 发送按钮
*/
- (void)emojiMenuView:(KInputBoxEmojiMenuView *)menuView
sendEmoji:(UIButton *)sendBut;

#pragma mark - 输入框代理部分

/**
通过输入的文字的变化，改变输入框的高度

@param inputBox 输入框
@param height 改变的高度
*/
- (void)inputBox:(KInputBoxView *)inputBox changeInputBoxHeight:(CGFloat)height;

/**
发送消息

@param inputBox 输入框
@param textMessage 输入的文字内容
*/
- (void)inputBox:(KInputBoxView *)inputBox
sendTextMessage:(NSString *)textMessage;

/**
状态改变

@param inputBox 输入框
@param fromStatus 上一个状态
@param toStatus 当前状态
*/
- (void)inputBox:(KInputBoxView *)inputBox
changeStatusForm:(KInputBoxStatus)fromStatus
to:(KInputBoxStatus)toStatus;

/**
点击输入框更多按钮事件

@param inputBox 输入框
@param inputStatus 当前状态
*/
- (void)inputBox:(KInputBoxView *)inputBox
clickMoreInput:(KInputBoxStatus)inputStatus;

```


###### 会话页面
会话页面其实不用多说的，就是一个普通的UITableView，如果需要重写会话视图，只需要对其Cell（KMessagesListTableViewCell）进行改动即可

###### 重点介绍聊天页面
众所周知聊天页面也是一个UITableView，其实聊天页面真正繁琐的是不同消息类型的不同Cell问题，还有就是在消息页面中布局的问题，由于消息页面出现不同的Cell较多，而且刷新频繁，所有要考虑很多UITableView优化的问题，如布局问题，AutoLayout虽然在布局方面有优势，但是会使性能下降，所以在RChat中消息页面及Cell中几乎都是使用的Frame布局，主要是为了提升性能。另一个问题就是计算行高的问题，对于UITableView优化已经是一个老生常谈的问题，我们Cell是需要先设置行高的，所以一般都需要对行高进行缓存，避免系统多次计算。
在写这个项目的时候我也看过好几篇IM界面的项目或者说demo，都不是很完整，几乎是不能直接使用的，所以写了这个项目，项目很多东西都是可以重写，继承和扩展。聊天消息支持的类型有文字（包含表情）、图片、视频、语音和邮件，其他类型需要根据需要自己定义，但是定义的时候建议继承KChatTableViewCell，方便统一处理。

    消息基类                   KChatTableViewCell
    文本消息（包含表情）         KChatTextTableViewCell
    图片消息                   KChatImageTableViewCell
    视频消息                   KChatVideoTableViewCell
    语音消息                   KChatVoiceTableViewCell
    邮件消息                   KChatMailTableViewCell
    消息代理                   KChatTableViewCellDelegate

###### KChatTableViewCellDelegate中提供的方法

```

@protocol KChatTableViewCellDelegate <NSObject>

/**
点击cell中的头像

@param tableViewCell 当前cell
@param messageModel 当前cell的数据
*/
- (void)chatTableViewCell:(KChatTableViewCell *)tableViewCell clickAvatarImageViewMessageModel:(KMessageModel *)messageModel;

/**
点击消息背景

@param tableViewCell 当前cell
@param messageModel 当前cell的数据
*/
- (void)chatTableViewCell:(KChatTableViewCell *)tableViewCell clickBackgroudImageViewMessageModel:(KMessageModel *)messageModel;

/**
当发送失败时点击，发送状态展示视图

@param tableViewCell 当前cell
@param conversationModel 会话信息
@param messageModel 消息
*/
- (void)chatTableViewCell:(KChatTableViewCell *)tableViewCell clickResendMessageWithConversationModel:(KConversationModel *)conversationModel messageModel:(KMessageModel *)messageModel;

/**
点击回复邮件

@param tableViewCell 当前cell
@param messageModel 当前cell的数据
*/
- (void)chatTableViewCell:(KChatMailTableViewCell *)tableViewCell replyMailMessageModel:(KMessageModel *)messageModel;

/**
点击回复全部

@param tableViewCell 当前cell
@param messageModel 当前cell的数据
*/
- (void)chatTableViewCell:(KChatMailTableViewCell *)tableViewCell
replyAllMaillMessageModel:(KMessageModel *)messageModel;

/**
点击转发邮件

@param tableViewCell 当前cell
@param messageModel 当前cell的数据
*/
- (void)chatTableViewCell:(KChatMailTableViewCell *)tableViewCell
transmitMailMessageModel:(KMessageModel *)messageModel;

/**
点击语音消息

@param tableViewCell 当前cell
@param messageModel 当前数据
*/
- (void)chatTableViewCell:(KChatVoiceTableViewCell *)tableViewCell clickVoiceMessageMessageModel:(KMessageModel *)messageModel;

```
###### 聊天消息控制器 KChatViewController 控制器使用Category的方式分类开发
    页面定义和文本消息         KChatViewController
    语音部分                 KChatViewController+Voice
    图片和视频部分            KChatViewController+Image

###### 消息页面提供几个经常使用的方法

```
// 重新刷新数据
- (void)reloadData;
// 移动到底部
- (void)scrollTableViewBottom ;
// 添加一条消息
- (void)addMessage:(KMessageModel *)model;
// 最后一条消息
- (KMessageModel *)lastMessage;

```
发送一条消息是，需要构造一个KMessageModel，调用addMessage:就可以，但是需要做缓存和上传到服务端的代码需要根据自己的需求写。


在项目中有什么疑问的，或者存在bug的，都可以给我提Issues,描述清楚问题和重现步骤，我将第一时间更新，如果有需要帮忙的同学可以发邮件到fshmjl@aliyun.com，最后麻烦大家点个Star哟。

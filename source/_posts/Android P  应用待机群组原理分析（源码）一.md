---
title: Android P  应用待机群组原理分析（源码）一
date: 2018-11-10 22:32:58
tags:
     - Android
     - framework
     - 源码
---
博客地址：http://blog.stayzeal.cn
问题描述：
===
在Android 9.0系统上，安装一个后台启动的App，如果直接启动后台服务并进行网络连接，就会出现网络连接超时的情况；但是打开该应用的一个Activity，再进行后台服务网络连接就没有网络超时的状况。
<!--more-->
问题原因：
===

查看Android 9.0变更文档，https://developer.android.com/about/versions/pie/power
Android 9 引入了一项新的电池管理功能，即应用待机群组。 应用待机群组可以基于应用最近使用时间和使用频率，帮助系统排定应用请求资源的优先级。 根据使用模式，每个应用都会归类到五个优先级群组之一中。 系统将根据应用所属的群组限制每个应用可以访问的设备资源。
五个群组按照以下特性将应用分组：
**活跃**
如果用户当前正在使用应用，应用将被归到“活跃”群组中，例如：
- 应用已启动一个 Activity
- 应用正在运行前台服务
- 应用的同步适配器与某个前台应用使用的 content provider 关联
- 用户在应用中点击了某个通知
- 如果应用处于“活跃”群组，系统不会对应用的作业、报警或 FCM 消息施加任何限制。

**工作集**
如果应用经常运行，但当前未处于活跃状态，它将被归到“工作集”群组中。 例如，用户在大部分时间都启动的某个社交媒体应用可能就属于“工作集”群组。 如果应用被间接使用，它们也会被升级到“工作集”群组中 。
如果应用处于“工作集”群组，系统会对它运行作业和触发报警的能力施加轻度限制。 如需了解详细信息，请参阅[电源管理限制](https://developer.android.com/topic/performance/power/power-details.html)。

**常用**
如果应用会定期使用，但不是每天都必须使用，它将被归到“常用”群组中。 例如，用户在健身房运行的某个锻炼跟踪应用可能就属于“常用”群组。
如果应用处于“常用”群组，系统将对它运行作业和触发报警的能力施加较强的限制，也会对高优先级 FCM 消息的数量设定限制。 如需了解详细信息，请参阅[电源管理限制](https://developer.android.com/topic/performance/power/power-details.html)。

**极少使用**
如果应用不经常使用，那么它属于“极少使用”群组。 例如，用户仅在入住酒店期间运行的酒店应用就可能属于“极少使用”群组。
如果应用处于“极少使用”群组，系统将对它运行作业、触发警报和接收高优先级 FCM 消息的能力施加严格限制。系统还会限制应用连接到网络的能力。 如需了解详细信息，请参阅[电源管理限制](https://developer.android.com/topic/performance/power/power-details.html)。

**从未使用**
安装但是从未运行过的应用会被归到“从未使用”群组中。 系统会对这些应用施加极强的限制。

通过`UsageStatsManager.getAppStandbyBucket()`可以获取App对应的分组。并且有一个**白名单**在以上五个分组之外，用户可以手动添加App到白名单中。

**以此我们可以推断，我的App处于从未使用分组，要想避免被限制连网，需要加入到白名单中。**

源码分析：
===
环境：
1、Linux
2、Vim编辑器
3、ag命令
4、AOSP
执行 `vim UsageStatsManager.java`，查找getAppStandbyBucket()的相关代码：
```
/**
 * The app is whitelisted for some reason and the bucket cannot be changed.
 * {@hide}
 */
@SystemApi
public static final int STANDBY_BUCKET_EXEMPTED = 5;
```
查看该成员变量注释猜测就是白名单：`STANDBY_BUCKET_EXEMPTED`。所以我们通过查看在哪使用了这个变量，就可以推断在哪里加入了白名单。
返回frameworks目录执行：`ag STANDBY_BUCKET_EXEMPTED`，在查找结果中发现这个应该是我们要查找的引用位置，因为其他结果不是做比较就是Test类：
```
base/services/usage/java/com/android/server/usage/AppStandbyController.java
40:import static android.app.usage.UsageStatsManager.STANDBY_BUCKET_EXEMPTED;
630:                        STANDBY_BUCKET_EXEMPTED, REASON_MAIN_DEFAULT);
633:                    STANDBY_BUCKET_EXEMPTED, REASON_MAIN_DEFAULT, false);
```
然后执行`vim base/services/usage/java/com/android/server/usage/AppStandbyController.java +630`命令，发现如下方法：
```
private void checkAndUpdateStandbyState(String packageName, @UserIdInt int userId,
            int uid, long elapsedRealtime) {
        if (uid <= 0) {
            try {
                uid = mPackageManager.getPackageUidAsUser(packageName, userId);
            } catch (PackageManager.NameNotFoundException e) {
                // Not a valid package for this user, nothing to do
                // TODO: Remove any history of removed packages
                return;
            }
        }
        final boolean isSpecial = isAppSpecial(packageName,
                UserHandle.getAppId(uid),
                userId);
        if (DEBUG) {
            Slog.d(TAG, "   Checking idle state for " + packageName + " special=" +
                    isSpecial);
        }
        if (isSpecial) {
            synchronized (mAppIdleLock) {
                mAppIdleHistory.setAppStandbyBucket(packageName, userId, elapsedRealtime,//630行
                        STANDBY_BUCKET_EXEMPTED, REASON_MAIN_DEFAULT)；//631行
            }
            maybeInformListeners(packageName, userId, elapsedRealtime,
                    STANDBY_BUCKET_EXEMPTED, REASON_MAIN_DEFAULT, false);
        } else {
        ...
}
```
分析代码，在`isAppSpecial`变量为`true`时，才会设置白名单，接下来我们看 `final boolean isSpecial = isAppSpecial(packageName,UserHandle.getAppId(uid),userId);`的相关代码：
```
/** Returns true if this app should be whitelisted for some reason, to never go into standby */
    boolean isAppSpecial(String packageName, int appId, int userId) {
        if (packageName == null) return false;
        // If not enabled at all, of course nobody is ever idle.
        if (!mAppIdleEnabled) {
            return true;
        }
        if (appId < Process.FIRST_APPLICATION_UID) {
            // System uids never go idle.
            return true;
        }
        if (packageName.equals("android")) {
            // Nor does the framework (which should be redundant with the above, but for MR1 we will
            // retain this for safety).
            return true;
        }
        if (mSystemServicesReady) {
            try {
                // We allow all whitelisted apps, including those that don't want to be whitelisted
                // for idle mode, because app idle (aka app standby) is really not as big an issue
                // for controlling who participates vs. doze mode.
                if (mInjector.isPowerSaveWhitelistExceptIdleApp(packageName)) {//加入白名单
                    return true;
                }
            } catch (RemoteException re) {
                throw re.rethrowFromSystemServer();
            }

            if (isActiveDeviceAdmin(packageName, userId)) {
                return true;
            }

            if (isActiveNetworkScorer(packageName)) {
                return true;
            }

            if (mAppWidgetManager != null
                    && mInjector.isBoundWidgetPackage(mAppWidgetManager, packageName, userId)) {
                return true;
            }

            if (isDeviceProvisioningPackage(packageName)) {
                return true;
            }
        }

```
重点看`mInjector.isPowerSaveWhitelistExceptIdleApp(packageName)`的实现代码：
```
boolean isPowerSaveWhitelistExceptIdleApp(String packageName) throws RemoteException {
         return mDeviceIdleController.isPowerSaveWhitelistExceptIdleApp(packageName);
}
```
接下来执行 `find . -name DeviceIdleController.java`命令，并定位到如下方法：
```
@Override public boolean isPowerSaveWhitelistExceptIdleApp(String name) {
            return isPowerSaveWhitelistExceptIdleAppInternal(name);
}
```
继续追踪：
```
public boolean isPowerSaveWhitelistExceptIdleAppInternal(String packageName) {
        synchronized (this) {
            return mPowerSaveWhitelistAppsExceptIdle.containsKey(packageName)
                    || mPowerSaveWhitelistUserApps.containsKey(packageName);
        }
}

```
这两个变量定义如下：
```
private final ArrayMap<String, Integer> mPowerSaveWhitelistAppsExceptIdle = new ArrayMap<>();
private final ArrayMap<String, Integer> mPowerSaveWhitelistUserApps = new ArrayMap<>();
```
到此我们找到了白名单存储的位置，即以上两个变量，接下来我们需要找到在哪里往这里面添加的App。我们可以直接搜索两个变量的引用，也可以直接 根据`isPowerSaveWhitelistExceptIdleAppInternal()`的方法名猜测，相关add方法为`addPowerSaveWhitelist*`，所以直接搜索`addPowerSaveWhitelist`找到`addPowerSaveWhitelistExceptIdleApp`方法（以上有`mPowerSaveWhitelistAppsExceptIdle`，`mPowerSaveWhitelistUserApps`两个变量，根据变量名我们猜测要找的是`mPowerSaveWhitelistUserApps`变量的add方法）：
```
 private final class BinderService extends IDeviceIdleController.Stub {
        @Override public void addPowerSaveWhitelistApp(String name) {
            if (DEBUG) {
                Slog.i(TAG, "addPowerSaveWhitelistApp(name = " + name + ")");
            }
            getContext().enforceCallingOrSelfPermission(android.Manifest.permission.DEVICE_POWER,
                    null);
            long ident = Binder.clearCallingIdentity();
            try {
                addPowerSaveWhitelistAppInternal(name);
            } finally {
                Binder.restoreCallingIdentity(ident);
            }
        }
}
```
以上代码可以获取的信息：
1、Binder通信的服务端
2、需要权限android.Manifest.permission.DEVICE_POWER
找到服务端了，这时我们可以找一下客户端在哪里调用了，执行`ag addPowerSaveWhitelistApp`命令，筛选结果：
```
base/packages/SettingsLib/src/com/android/settingslib/fuelgauge/PowerWhitelistBackend.java
135:            mDeviceIdleService.addPowerSaveWhitelistApp(pkg);
```
`vim ./base/packages/SettingsLib/src/com/android/settingslib/fuelgauge/PowerWhitelistBackend.java +135`:
```
public void addApp(String pkg) {
        try {
            mDeviceIdleService.addPowerSaveWhitelistApp(pkg);
            mWhitelistedApps.add(pkg);
        } catch (RemoteException e) {
            Log.w(TAG, "Unable to reach IDeviceIdleController", e);
        }
}
```
继续查看`mDeviceIdleService`在哪里赋值：
```
public PowerWhitelistBackend(Context context) {
        this(context, IDeviceIdleController.Stub.asInterface(
                ServiceManager.getService(DEVICE_IDLE_SERVICE)));
}
```
至此我们找到了添加白名单的方式。

总结：
===
以上我们分析了应用待机群组的源码，以及找到了添加白名单方式：
```
android.Manifest.permission.DEVICE_POWER//需要权限，需要和系统签名相同的App才能申请此权限
IDeviceIdleController mDeviceIdleController = IDeviceIdleController.Stub.asInterface(
                ServiceManager.getService(Context.DEVICE_IDLE_CONTROLLER));
mDeviceIdleController.addPowerSaveWhitelistApp(getPackageName());
```
关于查找如何添加白名单还有另外一种方式，Android官方文档中说用户可以通过可以通过设置手动添加App到白名单，所以从Setting的源码入手也是可以的。
以上我们只是分析了如何添加白名单，避免系统对我们的限制，但是还没分析，为什么不在白名单的应用会被用户限制联网，另一篇文章将会分析原因。


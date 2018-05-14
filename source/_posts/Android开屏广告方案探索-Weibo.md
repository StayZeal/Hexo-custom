---
title: Android开屏广告方案探索-Weibo
date: 2018-05-11 17:32:58
tags:
     - Android
     - 反编译
     - 广告
---
博客地址：[http://blog.stayzeal.cn-时光机](http://blog.stayzeal.cn)

说明：本文涉及到一些反编译的相关知识，如需要请查看http://blog.stayzeal.cn/2018/01/12/Android%E5%8F%8D%E7%BC%96%E8%AF%91%E5%B7%A5%E5%85%B7%E4%B8%8E%E6%8A%80%E5%B7%A7%E6%80%BB%E7%BB%93/
<!--more-->
通过apktool反编译apk，查看反编译后的AndroidManifest.xml文件，找到启动页面SplashActivity.class
```
...
import com.weibo.mobileads.controller.AdListener;
import com.weibo.mobileads.controller.WeiboAdTracking;
import com.weibo.mobileads.model.AdInfo;
import com.weibo.mobileads.model.AdRequest.ErrorCode;
import com.weibo.mobileads.util.AdUtil;
import com.weibo.mobileads.util.AdUtil.SaveDBType;
import com.weibo.mobileads.util.LogUtils;
import com.weibo.mobileads.view.FlashAd;
import com.weibo.mobileads.view.FlashAd.Orientation;
import com.weibo.mobileads.view.IAd;

public class SplashActivity extends Activity {
...
```
通过import的类名，我们猜测微博的广告相关类都在com.weibo.mobileads包下，在反编译的四个dex文件中，都找不到相关包，我们就猜测微博的广告是通过插件开发的，于是就这其他文件目录下查找有没有先关文件，最后在assets目录下找到了weiboad.jar，用jadx打开weiboad.jar，找到了com.weibo.mobileads包。说到插件化开发，我们来验证一下我们的猜测全局搜索weiboad.jar和DexClassLoader：
![ddddddf](http://img.blog.csdn.net/20171102183302260?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvQXV0aG9ySw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
跳转到如下代码：
```
 map2.put(str, new j("weiboad", "weiboad.jar", null, true, true, new String[]{"com.weibo.mobileads"}));
```
继续追踪我们发现是吧map2指向是a.b的对象：
```
package com.sina.weibo.bundlemanager;
...
/* compiled from: BundleConfigReader */
public class a {
    public static ChangeQuickRedirect a;
    private static Map<String, j> b = new LinkedHashMap();
...
```
查找a.b对象的引用：
![这里写图片描述](http://img.blog.csdn.net/20171102183504356?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvQXV0aG9ySw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
注意如下方法：
```
return PatchProxy.isSupport(new Object[0], null, a, true, 602, new Class[0], Collection.class) ? (Collection) PatchProxy.accessDispatch(new Object[0], null, a, true, 602, new Class[0], Collection.class) : b.values();
```
PatchProxy所在包为`import com.meituan.robust.PatchProxy`，用的是美团的插件技术，这里我们先挖个坑，我们先查看DexClassLoader的引用：
![这里写图片描述](http://img.blog.csdn.net/20171102183641579?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvQXV0aG9ySw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

我们看到有一个`com.meituan.robust.PatchExecutor`引用，所以我们基本可以确定微博采用的事美团的Robust框架来加载广告的。关于微博插件化加载我们就分析到这里，我们接下来看一下这个广告插件是怎么使用的。
启动微博，在广告显示的时候cmd执行` adb shell dumpsys activity top`命令，发现这时候显示的还是SplashActivity，所以微博的广告应该不是通过启动Activity实现的，观察SplashActivity中定义的变量：
```
public class SplashActivity extends Activity {
    public static ChangeQuickRedirect a;
    public static int b;
    public static boolean c = false;
    static long f = 0;
    long d;
    RelativeLayout e;
    private Handler g;
    private FlashAd h = null;
    private boolean i = false;
    private boolean j = false;
    private Runnable k;
    private String l = null;
    private ImageView m;
    private RoundedImageView n;
    private TextView o;
    private RelativeLayout p;
    private LinearLayout q;
    private RoundedImageView r;
    private TextView s;
    private TextView t;
    private AlphaAnimation u;

```
 猜测广告应该与`private FlashAd h = null;`有关，查找h的引用：
 ![这里写图片描述](http://img.blog.csdn.net/20171102183834723?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvQXV0aG9ySw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
在onDestory()方法中有`  this.h.closeAdDialog();`的引用，所以微博广告的展示可能是通过Dialog来实现的。
我们来看一下h对象所对应的类有如下方法：
```
  //FlashAd.class
  public void loadAd(AdRequest adRequest) {
        if (adRequest == null) {
            adRequest = new AdRequest();
        }
        if (this.flashAdManager != null) {
            if (this.context == null) {
                this.flashAdManager.a(null);
            } else {
                this.flashAdManager.a(adRequest);
            }
        }
    }

```

 继续看`this.flashAdManager.a(adRequest)`:
```
/* compiled from: FlashAdManager */
public class c extends a {
   ...
    public final synchronized void a(AdRequest adRequest) {
        try {
            if (!n()) {
                Context z = z();
                if (z == null) {
                    a(null);
                } else if (!AdUtil.checkConfig(z)) {
                    a(null);
                } else if (AdUtil.checkPermission(z)) {
                    this.h = adRequest;
                    y();
                    if (this.e instanceof FlashAd) {
                        this.o = false;
                        this.j = au.a(this);
                        this.j.a(adRequest);
                    }
                } else {
                    a(null);
                }
            }
        } catch (Exception e) {
            a(null);
        }
    }
    ...
}
```
 `this.j.a(adRequest)`由at.class(AdLoaderAndroid4.class)实现：
```
/* compiled from: AdLoaderAndroid4 */
public class at implements com.weibo.mobileads.au.a, Runnable {
     ...
	 public void a(AdRequest adRequest) {
	        new Thread(this).start();
	}
    ...
}

```
at.class实现了Runable接口，run()如下
```
/* compiled from: AdLoaderAndroid4 */
public class at implements com.weibo.mobileads.au.a, Runnable {
	 ...
	 public void run() {
	        synchronized (this) {
	            Context z = this.a.z();
	            if (z == null) {
	                a(ErrorCode.INTERNAL_ERROR, "activity was null while forming an ad request.");
	            } else {
	                try {
	                    a(z);
	                } catch (Exception e) {
	                    a(ErrorCode.INTERNAL_ERROR, "executeAdRequest:" + e.getMessage());
	                }
	            }
	        }
	    }
	...
}
```
 a(z)方法：
```

/* compiled from: AdLoaderAndroid4 */
public class at implements com.weibo.mobileads.au.a, Runnable {
	   ...
	   private synchronized void a(Context context) {
	        av avVar = new av();
	        this.c = avVar.a(this.a, context);
	        if (this.c != null) {
	            a(this.c, null);
	        } else {
	            this.a.a(avVar.a());
	            this.a.a(new b(this));
	        }
	    }
	    ...
}
```
`this.c = avVar.a(this.a, context)`方法如下:
```
/* compiled from: AdLoaderFromCacheHelper */
public class av {
	...
	public ErrorCode a(com.weibo.mobileads.controller.d dVar, Context context) {
	        if (a == -1) {
	            ac.a(context).c();
	            a = System.currentTimeMillis();
	        }
	        while (true) {
	            this.b = b(dVar, context);
	            if (this.b != null) {
	                String adWordId = this.b.getAdWordId();
	                File file;
	                switch (AnonymousClass1.b[this.b.getAdType().ordinal()]) {
	                    case 1:
	                    case AdInfo.TYPE_CLICK /*2*/:
	                        break;
	                    case AdInfo.TYPE_CLOSE /*3*/:
	                    case AdInfo.TYPE_TIMEOUT /*4*/:
	                        file = new File(AdUtil.getAdMd5Path(this.b.getImageUrl()));
	                        if (file.exists() && file.length() >= 10) {
	                            break;
	                        }
	                        ac.a(context).b(dVar.i(), adWordId);
	                        com.weibo.mobileads.util.c.c(AdUtil.getAdMd5Path(this.b.getImageUrl()));
	                        continue;
	                        break;
	                    case 5:
	                        file = new File(AdUtil.getAdMd5Path(this.b.getImageUrl()));
	                        if (file.exists() && file.length() >= 10) {
	                            break;
	                        }
	                        ac.a(context).b(dVar.i(), adWordId);
	                        com.weibo.mobileads.util.c.c(AdUtil.getAdMd5Path(this.b.getImageUrl()));
	                        continue;
	                        break;
	                    case 6:
	                        if (com.weibo.mobileads.util.c.a(AdUtil.getAdMd5Path(this.b.getImageUrl()) + "/WBAdRootDir/index.html")) {
	                            break;
	                        }
	                        ac.a(context).b(dVar.i(), adWordId);
	                        com.weibo.mobileads.util.c.c(AdUtil.getAdMd5Path(this.b.getImageUrl()));
	                        continue;
	                    default:
	                        continue;
	                }
	            }
	            if (this.b == null || AdType.EMPTY.equals(this.b.getAdType())) {
	                return ErrorCode.NO_FILL;
	            }
	            return null;
	        }
	    }
	...
}
```
` this.b = b(dVar, context)`方法，注意这个b（AdInfo）变量，待会我们还要看这个变量的引用：
```
/* compiled from: AdLoaderFromCacheHelper */
public class av {
 ...
	 private AdInfo b(com.weibo.mobileads.controller.d dVar, Context context) {
	        String E;
	        if (dVar instanceof b) {
	            E = ((b) dVar).E();
	        } else {
	            E = null;
	        }
	        List<AdInfo> a = ac.a(context).a(dVar.i(), E);
	        List arrayList = new ArrayList();
	        a netStatus = AdUtil.getNetStatus(context);
	        if (netStatus == a.UNKNOW && !(dVar.j() instanceof FlashAd)) {
	            return null;
	        }
	        if (!(a == null || a.isEmpty())) {
	            for (AdInfo adInfo : a) {
	                switch (AnonymousClass1.a[adInfo.getAllowNetwork().ordinal()]) {
	                    case 1:
	                        arrayList.add(adInfo);
	                        break;
	                    case AdInfo.TYPE_CLICK /*2*/:
	                        if (netStatus != a.GSM) {
	                            break;
	                        }
	                        arrayList.add(adInfo);
	                        break;
	                    case AdInfo.TYPE_CLOSE /*3*/:
	                        if (netStatus != a.WIFI) {
	                            break;
	                        }
	                        arrayList.add(adInfo);
	                        break;
	                    default:
	                        break;
	                }
	            }
	            List list = arrayList;
	        }
	        if (dVar instanceof c) {
	            return a(dVar, context, list);
	        }
	        return a(dVar, context, list, E);
	    }
	    ...
}
```
重点看`List<AdInfo> a = ac.a(context).a(dVar.i(), E)`这个方法：
```
/* compiled from: CacheDataHelper */
public class ae extends ad {
	...
	public synchronized List<AdInfo> a(String str, String str2) {
	        List<AdInfo> arrayList;
	        arrayList = new ArrayList();
	        try {
	            Cursor rawQuery;
	            long currentTimeMillis = System.currentTimeMillis();
	            String[] strArr;
	            if (TextUtils.isEmpty(str2)) {
	                strArr = new String[]{str};
	                rawQuery = a().rawQuery("select adcache.*,a.pvcount,l.allow_display from adcache left join adlinktips l on adcache.adid=l.adid left join (select * from addaycount where  julianday(datetime('now','localtime'))-julianday(addaycount.addate)<1) a on adcache.posid=a.posid and adcache.adid=a.adid where adcache.posid =? and adcache.visible = 1 and adcache.tempinvisible=1 and adcache.cachevalid=1 order by adcache.sortnum desc", strArr);
	            } else {
	                strArr = new String[]{str2, str};
	                rawQuery = a().rawQuery("select adcache.*,a.pvcount,l.allow_display from adcache left join adlinktips l on adcache.adid=l.adid left join (select * from addaycount where  julianday(datetime('now','localtime'))-julianday(addaycount.addate)<1 and uid=?) a on adcache.posid=a.posid and adcache.adid=a.adid where adcache.posid =? and adcache.visible = 1 and adcache.tempinvisible=1 and adcache.cachevalid=1 order by adcache.sortnum desc", strArr);
	            }
	            while (rawQuery.moveToNext()) {
	                int i = rawQuery.getInt(rawQuery.getColumnIndex("allowdaydisplaynum"));
	                int i2 = rawQuery.getInt(rawQuery.getColumnIndex("pvcount"));
	                if (i <= 0 || i2 <= 0 || i > i2) {
	                    AdInfo adInfoByCursor = AdInfo.getAdInfoByCursor(rawQuery);
	                    adInfoByCursor.setClickRects(ac.h(this.b).a(str, adInfoByCursor.getAdId()));
	                    adInfoByCursor.setDayDisplayNum(i);
	                    adInfoByCursor.setImageUrl(rawQuery.getString(rawQuery.getColumnIndex("imageurl")));
	                    adInfoByCursor.setAdurltype(rawQuery.getString(rawQuery.getColumnIndex("adurltype")));
	                    adInfoByCursor.setUrl(rawQuery.getString(rawQuery.getColumnIndex("url")));
	                    adInfoByCursor.setAdType(rawQuery.getInt(rawQuery.getColumnIndex("type")));
	                    if (currentTimeMillis < adInfoByCursor.getEndTime().getTime() && currentTimeMillis > adInfoByCursor.getBeginTime().getTime()) {
	                        List a = ac.g(this.b).a(str, adInfoByCursor.getAdId());
	                        if (a == null || a.size() == 0) {
	                            arrayList.add(adInfoByCursor);
	                        } else {
	                            adInfoByCursor.setAdTimes(a);
	                            AdInfo.b currentAdTime = adInfoByCursor.getCurrentAdTime();
	                            if (currentAdTime != null && currentAdTime.d() == 1) {
	                                arrayList.add(adInfoByCursor);
	                            }
	                        }
	                    }
	                }
	            }
	            a(rawQuery);
	        } catch (Throwable e) {
	            LogUtils.error("getAdListFromDBWithFilter", e);
	            a(null);
	        } catch (Throwable th) {
	            a(null);
	        }
	        return arrayList;
	    }
	...
}
```
看到这样一段代码
` rawQuery = a().rawQuery("select adcache.*,a.pvcount,l.allow_display from adcache left join adlinktips l on adcache.adid=l.adid left join (select * from addaycount where  julianday(datetime('now','localtime'))-julianday(addaycount.addate)<1) a on adcache.posid=a.posid and adcache.adid=a.adid where adcache.posid =? and adcache.visible = 1 and adcache.tempinvisible=1 and adcache.cachevalid=1 order by adcache.sortnum desc", strArr)`数据查询，我们看一下a()方法：
```
/* compiled from: CacheDataHelper */
public class ae extends ad {
	   ...
	  protected SQLiteDatabase a() {
	        if (a == null || !a.isOpen()) {
	            a = aj.a(this.b).getWritableDatabase();
	        }
	        return a;
	    }
	  ...
}
```
接着看`a = aj.a(this.b).getWritableDatabase()`:
```
/* compiled from: DbHelper */
public class aj extends SQLiteOpenHelper {
   ...
   public static aj a(Context context) {
        if (a == null) {
            synchronized (aj.class) {
                if (a == null) {
                    a = new aj(context);
                }
            }
        }
        return a;
    }

    public aj(Context context) {
        super(context.getApplicationContext(), "sinamobilead.db", null, 15);
    }
    ...
}
```
sinamobilead.db看到这个是不是很开心！原来广告数据不是直接从网络获取的，而是从数据库中读取的。
```
/* compiled from: AdLoaderFromCacheHelper */
public class av {
    private static long a = -1;
    private AdInfo b = null;
    ...
}
```
我们再回头看看变量b的引用（从数据中获取的AdInfo到底怎么使用了）：
![这里写图片描述](http://img.blog.csdn.net/20171102184019980?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvQXV0aG9ySw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

看一下第9个引用位置：
```
/* compiled from: AdLoaderFromCacheHelper */
public class av {
 ...
 public ErrorCode a(com.weibo.mobileads.controller.d dVar, Context context) {
        if (a == -1) {
            ac.a(context).c();
            a = System.currentTimeMillis();
        }
        while (true) {
            this.b = b(dVar, context);
            if (this.b != null) {
                String adWordId = this.b.getAdWordId();
                File file;
                switch (AnonymousClass1.b[this.b.getAdType().ordinal()]) {
                    case 1:
                    case AdInfo.TYPE_CLICK /*2*/:
                        break;
                    case AdInfo.TYPE_CLOSE /*3*/:
                    case AdInfo.TYPE_TIMEOUT /*4*/:
                        file = new File(AdUtil.getAdMd5Path(this.b.getImageUrl()));
                        if (file.exists() && file.length() >= 10) {
                            break;
                        }
                        ac.a(context).b(dVar.i(), adWordId);
                        com.weibo.mobileads.util.c.c(AdUtil.getAdMd5Path(this.b.getImageUrl()));
                        continue;
                        break;
                    case 5:
                        file = new File(AdUtil.getAdMd5Path(this.b.getImageUrl()));
                        if (file.exists() && file.length() >= 10) {
                            break;
                        }
                        ac.a(context).b(dVar.i(), adWordId);
                        com.weibo.mobileads.util.c.c(AdUtil.getAdMd5Path(this.b.getImageUrl()));
                        continue;
                        break;
                    case 6:
                        if (com.weibo.mobileads.util.c.a(AdUtil.getAdMd5Path(this.b.getImageUrl()) + "/WBAdRootDir/index.html")) {
                            break;
                        }
                        ac.a(context).b(dVar.i(), adWordId);
                        com.weibo.mobileads.util.c.c(AdUtil.getAdMd5Path(this.b.getImageUrl()));
                        continue;
                    default:
                        continue;
                }
            }
            if (this.b == null || AdType.EMPTY.equals(this.b.getAdType())) {
                return ErrorCode.NO_FILL;
            }
            return null;
        }
    }

```
```

    public static String getAdMd5Path(String str) {
        if (TextUtils.isEmpty(str)) {
            return "";
        }
        return getAdCachePath() + "/" + e.a(str);
    }
    ...
}
```
看看调用getAdMd5Path()的相关代码，我们可以猜测大体流程从数据库中加载广告信息AdInfo，然后根据AdInfo从本地缓存读取image、video或者html。那么什么时候下载（缓存这些数据呢）？
既然读数据需要获取数据库，缓存目录，那么写数据也需要这些，我们看一下getAdMd5Path()的所有调用，并追踪选中的调用位置：
![这里写图片描述](http://img.blog.csdn.net/20171102184123776?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvQXV0aG9ySw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

查看调用堆栈，最后找到下面这个方法，但是找不到直接调用：
```
package com.weibo.mobileads;
/* compiled from: FetchDataTask */
public final class ax extends w<Void, String, ErrorCode> {

    protected ErrorCode a(Void... voidArr) {
        try {
            return e();
        } catch (Exception e) {
            this.j.putString("msg", e.getMessage().toString());
            return ErrorCode.INTERNAL_ERROR;
        }
    }
}
```
```
/* compiled from: ADAsyncTask */
public abstract class w<Params, Progress, Result> {
...
```
方法`protected abstract Result a(Params... paramsArr)`
Result  是泛型，FetchDataTask又没有其他方法的实现该方法，所以`protected ErrorCode a(Void... voidArr)`就是`protected abstract Result a(Params... paramsArr)`的实现，我们查看调用堆栈，找到如下方法：
```
/* compiled from: ADAsyncTask */
  public final w<Params, Progress, Result> c(Params... paramsArr) {
        return a(f, (Object[]) paramsArr);
    }
```
该方法的调用如下：
![这里写图片描述](http://img.blog.csdn.net/20171102184306730?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvQXV0aG9ySw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
这里可能是所有需要刷新广告的调用位置，关于刷新的调用流程就分析到这。我们再来看一下是怎么刷新的，上面FetchDataTask中的 `protected ErrorCode a(Void... voidArr)`调用了如下方法：
```
/* compiled from: FetchDataTask */
public final class ax extends w<Void, String, ErrorCode> {
  ...
  private ErrorCode e() throws WeiboIOException, BackgroudForbiddenException {
        if (!this.h && AdUtil.isBackgroundRunning()) {
            return ErrorCode.NETWORK_ERROR;
        }
        if (this.e == null) {
            return ErrorCode.INTERNAL_ERROR;
        }
        synchronized (this) {
            AdUtil.getNetStatus(this.e);
            if (h.b(this.e) != -1) {
                StringBuffer stringBuffer = new StringBuffer();
                Bundle bundle = new Bundle();
                if (this.f != null) {
                    for (Entry entry : this.f.entrySet()) {
                        if (entry.getValue() != null) {
                            bundle.putString((String) entry.getKey(), entry.getValue().toString());
                            stringBuffer.append((String) entry.getKey()).append("=").append(entry.getValue().toString()).append(",");
                        }
                    }
                    bundle.putShort("entity_type", (short) 3);
                    bundle.putString("ad_token", AdUtil.getEncryptedTime());
                }
                String a = a.a();
                if (this.h) {
                    a = a.b();
                    this.j.putString("type", "actionad");
                } else {
                    this.j.putString("type", "sdkad");
                }
                this.j.putString("is_ok", "0");
                String trim = WeiboHttpHelper.openUrlStringPostRequest(this.e.getApplicationContext(), 903, a, null, bundle).trim();
                if (this.d != null) {
                    String[] split = this.d.split(",");
                    if (trim.length() > 0 && split.length > 0) {
                        if (trim.endsWith("OK")) {
                            this.j.putString("is_ok", "1");
                            for (String str : split) {
                                ac.a(this.e).e(str);
                                ac.e(this.e).b(str);
                                ac.f(this.e).b(str);
                                ac.j(this.e).c();
                            }
                            if (KeyValueStorageUtils.getInt(this.e, "upload_quickly_close", 0) > 0) {
                                KeyValueStorageUtils.setLong(this.e, "closequicklytime", 0);
                                KeyValueStorageUtils.setInt(this.e, "upload_quickly_close", 0);
                            }
                            f();
                            Object substring = trim.substring(0, trim.length() - 2);
                            if (TextUtils.isEmpty(substring)) {
                                return null;
                            }
                            return a(substring, split);
                        }
                        return ErrorCode.INTERNAL_ERROR;
                    }
                }
                return ErrorCode.INTERNAL_ERROR;
            }
            return ErrorCode.NETWORK_ERROR;
        }
    }
   ...
}
```
注意这段代码` String trim = WeiboHttpHelper.openUrlStringPostRequest(this.e.getApplicationContext(), 903, a, null, bundle).trim();`获取广告信息网络请求，把请求的数据传给如下方法， `return a(substring, split)`：
```
private ErrorCode a(String str, String[] strArr) {
        boolean z = true;
        i.a(this.e).a();
        JSONObject jSONObject = new JSONObject(str);
        if (jSONObject.has("background_delay_display_time") || jSONObject.has("show_push_splash_ad") || jSONObject.has("needlocation")) {
            if (jSONObject.has("background_delay_display_time")) {
                try {
                    KeyValueStorageUtils.setInt(this.e, "background_delay_display_time", jSONObject.getInt("background_delay_display_time"));
                } catch (JSONException e) {
                }
            }
            try {
                if (jSONObject.has("show_push_splash_ad")) {
                    try {
                        KeyValueStorageUtils.setBoolean(this.e, "show_push_splash_ad", jSONObject.getBoolean("show_push_splash_ad"));
                    } catch (JSONException e2) {
                        int i = jSONObject.getInt("show_push_splash_ad");
                        Context context = this.e;
                        String str2 = "show_push_splash_ad";
                        if (i <= 0) {
                            z = false;
                        }
                        KeyValueStorageUtils.setBoolean(context, str2, z);
                    }
                }
                JSONArray jSONArray = jSONObject.getJSONArray("ads");
            } catch (Exception e3) {
                return ErrorCode.INTERNAL_ERROR;
            }
        }
        jSONArray = new JSONArray(str);
        List arrayList = new ArrayList();
        Set hashSet = new HashSet();
        final Set hashSet2 = new HashSet();
        if (jSONArray != null && jSONArray.length() > 0) {
            for (int i2 = 0; i2 < jSONArray.length(); i2++) {
                JSONObject jSONObject2 = jSONArray.getJSONObject(i2);
                if (!TextUtils.isEmpty(jSONObject2.optString("posid"))) {
                    hashSet.add(jSONObject2.optString("adwordid", null));
                    KeyValueStorageUtils.setLong(this.e, "quick_click_time", (long) ((jSONObject2.optInt("quick_click_time", 0) * 60) * 1000));
                    KeyValueStorageUtils.setInt(this.e, "quick_click_times", jSONObject2.optInt("quick_click_times", 0));
                    KeyValueStorageUtils.setLong(this.e, "quick_click_noshow_time", (long) ((jSONObject2.optInt("quick_click_noshow_time", 0) * 60) * 1000));
                    AdInfo adInfo = new AdInfo(this.e, jSONObject2);
                    if (adInfo != null) {
                        if (adInfo.isAdInfoJsonParsedValid()) {
                            hashSet2.add(e.a(adInfo.getImageUrl()));
                            List<AdInfo.a> clickRects = adInfo.getClickRects();
                            if (clickRects != null && clickRects.size() > 0) {
                                for (AdInfo.a aVar : clickRects) {
                                    if (aVar != null) {
                                        if (!TextUtils.isEmpty(aVar.f())) {
                                            hashSet2.add(e.a(aVar.f()));
                                        }
                                        if (!TextUtils.isEmpty(aVar.e())) {
                                            hashSet2.add(e.a(aVar.e()));
                                        }
                                    }
                                }
                            }
                            if (!(AdType.EMPTY.equals(adInfo.getAdType()) || AdType.HTML5.equals(adInfo.getAdType()))) {
                                Options picOptions = AdUtil.getPicOptions(new File(AdUtil.getAdMd5Path(adInfo.getImageUrl())));
                                if (picOptions != null) {
                                    adInfo.setImageWidth(picOptions.outWidth);
                                    adInfo.setImageHeight(picOptions.outHeight);
                                }
                            }
                            arrayList.add(adInfo);
                        } else if (!AdType.HTML5.equals(adInfo.getAdType()) || !AdType.VIDEO.equals(adInfo.getAdType())) {
                            this.i = true;
                        }
                    }
                }
            }
        }
        ac.a(this.e).a(this.d, arrayList);
        File cacheDir = AdUtil.getCacheDir();
        if (cacheDir.isDirectory()) {
            File[] listFiles = cacheDir.listFiles(new FilenameFilter(this) {
                final /* synthetic */ ax b;

                public boolean accept(File file, String str) {
                    boolean z = !hashSet2.contains(str);
                    if (!z) {
                        return z;
                    }
                    long currentTimeMillis = System.currentTimeMillis();
                    if (file.lastModified() <= 0 || currentTimeMillis - file.lastModified() <= 604800000) {
                        return false;
                    }
                    return z;
                }
            });
            if (listFiles != null && listFiles.length > 0) {
                for (int i3 = 0; i3 < listFiles.length; i3++) {
                    if (listFiles[i3].isDirectory()) {
                        c.a(listFiles[i3]);
                    } else {
                        listFiles[i3].delete();
                    }
                }
            }
        }
        return null;
    }

```
`AdInfo adInfo = new AdInfo(this.e, jSONObject2);`这一行把广告信息封装成AdInfo类，加载广告信息的时候也是根据这个类从缓存中加载数据，这个类的构造方法非常复杂：
```
public AdInfo(Context context, JSONObject jSONObject) {
        int i;
        int i2 = Integer.MAX_VALUE;
        boolean z = true;
        boolean z2 = false;
        this.adId = jSONObject.optString("adid", null);
        this.adWordId = jSONObject.optString("adwordid", null);
        this.imageUrl = jSONObject.optString("imageurl", null);
        String optString = jSONObject.optString("type", null);
        this.posId = jSONObject.optString("posid");
        this.adWord = jSONObject.optString("adword", null);
        setBeginTime(jSONObject.optString("begintime", null));
        setEndTime(jSONObject.optString("endtime", null));
        this.url = jSONObject.optString("url", null);
        this.adUrl = jSONObject.optString("adurl", null);
        setDisplayTime(jSONObject.optString("displaytime", null));
        setAdurltype(jSONObject.optInt("adurltype") + "");
        setSortNum(jSONObject.optInt("sortnum"));
        setDayClickNum(jSONObject.optInt("dayclicknum"));
        if (jSONObject.optInt("allowdaydisplaynum") == 0) {
            i = Integer.MAX_VALUE;
        } else {
            i = jSONObject.optInt("allowdaydisplaynum");
        }
        setDayDisplayNum(i);
        setAllowNetwork(jSONObject.optInt("allownetwork"));
        if (jSONObject.optInt("displaynum") != 0) {
            i2 = jSONObject.optInt("displaynum");
        }
        setDisplayNum(i2);
        setReactivate(jSONObject.optInt("reactivate"));
        setShowCloseButtonType(jSONObject.optInt("showclosebuttontype", e.BANNERAD_CAN.a()));
        this.tokenId = jSONObject.optString("tokenid", null);
        this.downloadPackageName = jSONObject.optString("downloadpackagename", null);
        this.downloadActivity = jSONObject.optString("downloadactivity", null);
        this.downloadVersion = jSONObject.optInt("downloadversion");
        setWeiboType(jSONObject.optInt("weibotype"));
        this.showAttention = jSONObject.optInt("showattention");
        this.showForward = jSONObject.optInt("showforward");
        setWeiboUserId(jSONObject.optString("ggzuid", null));
        setWeiboId(jSONObject.optString("weiboid", null));
        setWeiboTopic(jSONObject.optString("weibotitle", null));
        setWeiboContent(jSONObject.optString("weibocontent", null));
        setNeedGsid(jSONObject.optInt("needgsid"));
        setMonitorUrl(jSONObject.optString("monitor_url", null));
        setMonitorCode(jSONObject.optString("moinitorcode", null));
        setMonitorClickUrl(jSONObject.optString("monitorclickurl", null));
        setMonitorClickCode(jSONObject.optString("moinitorclickcode", null));
        setAllowSkip(jSONObject.optInt("allowskip"));
        setLinkAdId(jSONObject.optString("linkadid"));
        setAdUrlBackup(jSONObject.optString("adurl_backup"));
        setContent_rect(jSONObject.optString("content_rect"));
        setWifiDownload(jSONObject.optInt("wifidownload"));
        try {
            List arrayList;
            JSONArray jSONArray;
            int i3;
            boolean z3;
            boolean z4;
            final String e;
            if (jSONObject.has("times") && !jSONObject.isNull("times")) {
                arrayList = new ArrayList();
                jSONArray = jSONObject.getJSONArray("times");
                i = 0;
                i2 = 0;
                for (i3 = 0; i3 < jSONArray.length(); i3++) {
                    b a = b.a(jSONArray.getJSONObject(i3));
                    if (a != null) {
                        arrayList.add(a);
                        i += a.b();
                        i2 += a.a();
                    }
                }
                if (getDisplayNum() < i) {
                    setDisplayNum(i);
                }
                if (getDayClickNum() < i2) {
                    setDayClickNum(i2);
                }
                setAdTimes(arrayList);
            }
            if (!jSONObject.has("click_rects") || jSONObject.isNull("click_rects")) {
                z3 = true;
            } else {
                arrayList = new ArrayList();
                jSONArray = jSONObject.getJSONArray("click_rects");
                int length = jSONArray.length();
                i3 = 0;
                z3 = true;
                while (i3 < length) {
                    a a2 = a.a(jSONArray.getJSONObject(i3));
                    if (TextUtils.isEmpty(a2.e())) {
                        z4 = z3;
                    } else {
                        e = a2.e();
                        z4 = com.weibo.mobileads.util.g.a(context, this.wifiDownload == 1, a2.e(), new com.weibo.mobileads.util.g.a(this) {
                            final /* synthetic */ AdInfo b;

                            public void a(boolean z, String str) {
                                if (z) {
                                    this.b.isDownNewFile = true;
                                }
                                Bundle bundle = new Bundle();
                                bundle.putString("adid", this.b.getAdId());
                                bundle.putString("url", e);
                                bundle.putString("is_ok", z ? "1" : "0");
                                bundle.putString("msg", str);
                                AdUtil.recordNetCacheActCode(bundle);
                            }
                        });
                        if (z3 && z4) {
                            z4 = true;
                        } else {
                            z4 = false;
                        }
                    }
                    if (!TextUtils.isEmpty(a2.f())) {
                        final String f = a2.f();
                        z3 = com.weibo.mobileads.util.g.a(context, this.wifiDownload == 1, a2.f(), new com.weibo.mobileads.util.g.a(this) {
                            final /* synthetic */ AdInfo b;

                            public void a(boolean z, String str) {
                                if (z) {
                                    this.b.isDownNewFile = true;
                                }
                                Bundle bundle = new Bundle();
                                bundle.putString("adid", this.b.getAdId());
                                bundle.putString("url", f);
                                bundle.putString("is_ok", z ? "1" : "0");
                                bundle.putString("msg", str);
                                AdUtil.recordNetCacheActCode(bundle);
                            }
                        });
                        if (z4 && z3) {
                            z4 = true;
                        } else {
                            z4 = false;
                        }
                    }
                    arrayList.add(a2);
                    i3++;
                    z3 = z4;
                }
                setClickRects(arrayList);
            }
            com.weibo.mobileads.util.g.a anonymousClass3 = new com.weibo.mobileads.util.g.a(this) {
                final /* synthetic */ AdInfo a;

                {
                    this.a = r1;
                }

                public void a(boolean z, String str) {
                    if (z) {
                        this.a.isDownNewFile = true;
                    }
                    Bundle bundle = new Bundle();
                    bundle.putString("adid", this.a.getAdId());
                    bundle.putString("url", this.a.getImageUrl());
                    bundle.putString("is_ok", z ? "1" : "0");
                    bundle.putString("msg", str);
                    AdUtil.recordNetCacheActCode(bundle);
                }
            };
            if (AdType.TEXT.getValue().equals(optString)) {
                setAdType(AdType.TEXT);
                z2 = true;
                z = z3;
            } else if (AdType.EMPTY.getValue().equals(optString)) {
                setAdType(AdType.EMPTY);
                z2 = true;
            } else if (AdType.VIDEO.getValue().equals(optString)) {
                setAdType(AdType.VIDEO);
                if (f.a(getModelContent_rect())) {
                    if (getWifiDownload() != 1) {
                        z = false;
                    }
                    z2 = com.weibo.mobileads.util.g.a(context, z, this.imageUrl, anonymousClass3);
                    z = z3;
                } else {
                    z = z3;
                }
            } else {
                if (AdType.HTML5.getValue().equals(optString)) {
                    setAdType(AdType.HTML5);
                    if (com.weibo.mobileads.util.g.a(context, this.wifiDownload == 1, this.imageUrl, anonymousClass3)) {
                        if (com.weibo.mobileads.util.c.a(AdUtil.getAdMd5Path(this.imageUrl))) {
                            try {
                                com.weibo.mobileads.util.c.b(AdUtil.getAdMd5Path(this.imageUrl), AdUtil.getAdMd5Path(this.imageUrl) + "_html");
                                com.weibo.mobileads.util.c.a(AdUtil.getAdMd5Path(this.imageUrl) + "_html", AdUtil.getAdMd5Path(this.imageUrl));
                            } catch (IOException e2) {
                                e2.printStackTrace();
                            }
                        }
                        z2 = true;
                        z = z3;
                    }
                } else if (AdType.WEIBO.getValue().equals(optString)) {
                    setAdType(AdType.WEIBO);
                    z = z3;
                } else {
                    e = jSONObject.optString("imgextname", null);
                    if (AdType.IMAGE.getValue().equals(optString) && TextUtils.isEmpty(e)) {
                        e = "png";
                    }
                    if (AdType.IMAGE.getValue().equals(optString) || AdUtil.isImage(e)) {
                        if (e.equals("gif")) {
                            setAdType(AdType.GIF);
                        } else {
                            setAdType(AdType.IMAGE);
                        }
                        if (getAdWordId().toLowerCase().endsWith(".gif")) {
                            e = getAdWordId();
                        } else {
                            e = getAdWordId() + "." + e;
                        }
                        setFileName(e);
                        if (this.wifiDownload == 1) {
                            z4 = true;
                        } else {
                            z4 = false;
                        }
                        z4 = com.weibo.mobileads.util.g.a(context, z4, this.imageUrl, anonymousClass3);
                        if (jSONObject.has("limageurl") && !TextUtils.isEmpty(jSONObject.getString("limageurl"))) {
                            if (this.wifiDownload != 1) {
                                z = false;
                            }
                            com.weibo.mobileads.util.g.a(context, z, jSONObject.getString("limageurl"));
                        }
                        z = z3;
                        z2 = z4;
                    }
                }
                z = z3;
            }
            if (z2 && r2) {
                this.mIsValid = true;
                if (this.isDownNewFile) {
                    AdUtil.recordReadyActCode(getAdId());
                    return;
                }
                return;
            }
            this.mIsValid = false;
        } catch (JSONException e3) {
            e3.printStackTrace();
        }
    }

```
这个方法非常复杂，我是没有仔细看的。但是到了这我就有一个问题，广告接口信息是请求到了，但是里面的图片，视频等信息是什么时候加载的呢？这时候我还没有找到加载的地方，由于项目太复杂，而且名字还混淆了，查看调用堆栈的时候我们不可能把每个调用地方都查看一遍，所以可能是某些关键信息会被我们漏掉，那么怎么办呢？这个时候就需要猜测了，既然是网络加载图片或者视频，那么他们都是下载文件，很有可能需要一个工具类来进行加载，在`package com.weibo.mobileads.util`我们一次查看，发现了这个类，其中有如下方法：
```
/* compiled from: NetUtil */
public class g {

    //方法1
    public static boolean a(Context context, String str, File file, a aVar) {
        String str2;
        String str3 = "";
        try {
            InputStream openUrlStream = WeiboHttpHelper.openUrlStream(context.getApplicationContext(), str, "GET", null, null, null, 903, false);
            if (aVar != null) {
                aVar.a(true, str3);
            }
            return a(openUrlStream, file);
        } catch (WeiboIOException e) {
            str2 = e.getMessage().toString();
            if (aVar != null) {
                aVar.a(false, str2);
            }
            return false;
        } catch (BackgroudForbiddenException e2) {
            str2 = e2.getMessage().toString();
            if (aVar != null) {
                aVar.a(false, str2);
            }
            return false;
        } catch (Exception e3) {
            str2 = e3.getMessage().toString();
            if (aVar != null) {
                aVar.a(false, str2);
            }
            return false;
        }
    }

  // 方法2
   public static boolean a(Context context, boolean z, String str, a aVar) {
        if (!c.b(AdUtil.getAdCachePath())) {
            c.b(new File(AdUtil.getAdCachePath()));
        }
        String adMd5Path = AdUtil.getAdMd5Path(str);
        if (c.a(adMd5Path) || c.b(adMd5Path)) {
            return true;
        }
        if (z && h.b(context) != 1) {
            return false;
        }
        File file = new File(adMd5Path);
        adMd5Path = "";
        if (a(context, str, file, aVar)) {
            return true;
        }
        return false;
    }



}
```
方法1是进行网络请求，方法2调用了方法1（方法2中调用了`AdUtil.getAdMd5Path(str)`说明我们前面的思路是没问题的），下面是方法2被调用的地方：
![这里写图片描述](http://img.blog.csdn.net/20171102184538418?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvQXV0aG9ySw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
发现好多调用都是在AdInfo的构造方法中，至此我们应该就可以猜到在广告信息请求完之后在构造AdInfo对象的过程中，就把图片和视频缓存下来了。

#### 文章思路
（为了防止大家对文章思路有些迷惑，并且担心自己没有解释清楚，特有以下说明）：
先找到展示广告的UI，然后找到了相关UI，所在的包（代码文件位置，以及加载方式-美团热更新的解决方案），然后找到UI从缓存中读取数据，然后根据缓存目录，找到写缓存的相关流程，在查找缓存文件加载的过程时候，主要靠猜测找到了相关代码，最后所有的线索都能串起来了。在反编译的过程中一步步分析很重要，猜测也同样重要，这样可以减少很多工作量。由于流程太过复杂，没能面面俱到，抱歉！
 
#### 方案总结：
1、UI的实现：Weibo的广告展示页面种类并不复杂，只需设置好固定的种类就行，比如图片，GIF，视频和WebView。并且weibo通过java代码设置各种View的布局，没有使用xml文件。
2、数据获取：在广告加载之前，缓存广告数据，包括一个广告数据的接口(接口信息保存到数据库中)，接口里包含图片地址，视频地址，网页地址，根据这些地址加载到缓存目录的文件系统中，等再次展示广告的时候，直接从缓存中读取数据。
3、展示时机：主要判断逻辑都在SplashActivity页面，所以应该是在每次启动的时候判断是否展示。











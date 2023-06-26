package com.example.test_push

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.PendingIntent.FLAG_IMMUTABLE
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "test"
        private const val METHOD_GET_LIST = "startPush"
    }

    private lateinit var channel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel.setMethodCallHandler { methodCall: MethodCall, result: MethodChannel.Result ->
            if (methodCall.method == METHOD_GET_LIST) {
                val name = methodCall.argument<String>("name").toString()
                val age = methodCall.argument<Int>("age")
                Log.d("Android", "name = ${name}, age = $age")
                sendNotification()
                val list = listOf("data0", "data1", "data2")
                result.success(list)
            } else
                result.notImplemented()
        }
    }

    override fun onNewIntent(intent: Intent) {
        Log.d("Android", intent.toString())
        super.onNewIntent(intent)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val intent = intent
        if (intent != null) {
            Log.d("Android", "停止状態からの復帰です")
            Log.d("Android", intent.toString())
            Log.d("Android", intent.getStringExtra("起動フラグ").toString())
        }
    }

    private fun sendNotification() {
        val channelId = "channel_id"
        val channelName = "channel_name"
        val channelDescription = "channel_description "
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = channelDescription
            }
            /// チャネルを登録
            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)

            // インテントの作成
            val intent = Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            }
            intent.putExtra("起動フラグ", "起動")
            val intent2 = Intent(this, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
            }
            intent2.putExtra("起動フラグ", "起動2")
            val pendingIntent = PendingIntent.getActivity(this, 5, intent, FLAG_IMMUTABLE)
            val pendingIntent2 = PendingIntent.getActivity(this, 6, intent2, FLAG_IMMUTABLE)

            val builder = NotificationCompat.Builder(this, channelId)
                .setSmallIcon(R.drawable.launch_background)    /// 表示されるアイコン
                .setContentTitle("ハローkotlin!!")                  /// 通知タイトル
                .setContentText("今日も1日がんばるぞい!")           /// 通知コンテンツ
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setContentIntent(pendingIntent)
                .setAutoCancel(true)
            val notificationId = 1
            notificationManager.notify(notificationId, builder.build())

            val builder2 = NotificationCompat.Builder(this, channelId)
                .setSmallIcon(R.drawable.launch_background)    /// 表示されるアイコン
                .setContentTitle("2ハローkotlin!!")                  /// 通知タイトル
                .setContentText("2今日も1日がんばるぞい!")           /// 通知コンテンツ
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
                .setContentIntent(pendingIntent2)
                .setAutoCancel(true)
            val notificationId2 = 2
            notificationManager.notify(notificationId2, builder2.build())
        }
    }
}

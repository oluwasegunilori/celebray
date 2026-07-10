package com.shegz.celebray

import android.content.ContentResolver
import android.provider.ContactsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.shegz.celebray/contacts"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "lastContactedTimes" -> {
                        try {
                            result.success(readLastContactedTimes(contentResolver))
                        } catch (e: Exception) {
                            result.error("CONTACTS_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun readLastContactedTimes(resolver: ContentResolver): Map<String, Long> {
        val map = mutableMapOf<String, Long>()
        val projection = arrayOf(
            ContactsContract.Contacts._ID,
            ContactsContract.Contacts.LAST_TIME_CONTACTED,
        )
        resolver.query(
            ContactsContract.Contacts.CONTENT_URI,
            projection,
            "${ContactsContract.Contacts.LAST_TIME_CONTACTED} > 0",
            null,
            null,
        )?.use { cursor ->
            val idIdx = cursor.getColumnIndex(ContactsContract.Contacts._ID)
            val lastIdx = cursor.getColumnIndex(ContactsContract.Contacts.LAST_TIME_CONTACTED)
            while (cursor.moveToNext()) {
                val id = cursor.getString(idIdx)
                val last = cursor.getLong(lastIdx)
                if (last > 0L) {
                    map[id] = last
                }
            }
        }
        return map
    }
}

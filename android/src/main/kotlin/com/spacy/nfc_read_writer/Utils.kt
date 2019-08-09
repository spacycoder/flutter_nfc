package com.spacy.nfc_read_writer

import android.content.Intent
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.Ndef
import android.nfc.tech.NdefFormatable
import android.util.Log
import java.lang.Exception
import android.nfc.NdefMessage
import android.nfc.NdefRecord

const val NFC_STATE_ENABLED = "enabled"
const val NFC_STATE_DISABLED = "disabled"
const val NFC_STATE_NOT_SUPPORTED = "notSupported"

fun bytesToString(bytes: ByteArray?): String {
	if (bytes == null) return ""
	return bytes.joinToString("") {
		String.format("%02x", it)
	}
}

fun getNfcState(adapter: NfcAdapter?): String {
	return when {
		adapter == null -> NFC_STATE_NOT_SUPPORTED
		adapter.isEnabled -> NFC_STATE_ENABLED
		else -> NFC_STATE_DISABLED
	}
}

fun getActivityNfcStartupData(intent: Intent): Map<String, Any?>? {
	val action = intent.action ?: return null

	val tag = intent.getParcelableExtra<Tag>(NfcAdapter.EXTRA_TAG)
	when (action) {
		NfcAdapter.ACTION_NDEF_DISCOVERED -> {
			val message = ndefToMap(tag)
			Log.d(PLUGIN_TAG, "action ACTION_NDEF_DISCOVERED $message")
			return message
		}
		NfcAdapter.ACTION_TECH_DISCOVERED -> {
			for (tagTech in tag.techList) {
				Log.d(PLUGIN_TAG, "action ACTION_TECH_DISCOVERED")
				if (tagTech == NdefFormatable::class.java.name) {
					val message = ndefToMap(tag)
					Log.d(PLUGIN_TAG, "ACTION_TECH_DISCOVERED NdefFormatable: $message")
					return message
				} else if (tagTech == Ndef::class.java.name) {
					val message = ndefToMap(tag)
					Log.d(PLUGIN_TAG, "ACTION_TECH_DISCOVERED Ndef: $message")
					return message
				}
			}
		}
		NfcAdapter.ACTION_TAG_DISCOVERED -> {
			val message = ndefToMap(tag)
			Log.d(PLUGIN_TAG, "action ACTION_TAG_DISCOVERED $message")
			return message
		}
	}

	return null
}

inline fun <reified T> toArray(list: List<*>): Array<T> {
    return (list as List<T>).toTypedArray()
}


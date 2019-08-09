package com.spacy.nfc_read_writer

import android.nfc.NdefMessage
import android.nfc.NdefRecord
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.Ndef
import android.nfc.tech.NdefFormatable
import java.nio.charset.Charset
import kotlin.experimental.and
import android.nfc.TagLostException
import android.nfc.FormatException
import java.io.IOException
import android.util.Log

private const val KEY_ERROR = "error"
private const val KEY_MESSAGE = "message"
private const val KEY_ID = "id"
private const val KEY_PAYLOAD = "payload"
private const val KEY_TECH_LIST = "techList"

fun ndefToMap(tag: Tag?): Map<String, Any?> {
	return try {
		val ndef = Ndef.get(tag)
		val id = bytesToString(tag?.id)
		val techList = tag?.techList?.toList()
		val records = getRecords(ndef.cachedNdefMessage)
		val message = mapOf(KEY_ID to id, KEY_PAYLOAD to records, KEY_TECH_LIST to techList)
		mapOf(KEY_ERROR to "", KEY_MESSAGE to message)
	} catch (e: Exception) {
		mapOf(KEY_ERROR to "Cannot parse NDEF message: $e", KEY_MESSAGE to null)
	}
}

fun getRecords(message: NdefMessage?): List<String> {
	var payload = listOf(String())
	if (message == null) return payload
	payload = message.records.map { r -> recordToString(r) }
	return payload
}

/*
     * payload[0] contains the "Status Byte Encodings" field, per the
     * NFC Forum "Text Record Type Definition" section 3.2.1.
     *
     * bit7 is the Text Encoding Field.
     *
     * if (Bit_7 == 0): The text is encoded in UTF-8 if (Bit_7 == 1):
     * The text is encoded in UTF16
     *
     * Bit_6 is reserved for future use and must be set to zero.
     *
     * Bits 5 to 0 are the length of the IANA language code.
*/
// https://developer.android.com/reference/android/nfc/NdefRecord.html
fun recordToString(record: NdefRecord): String {
	if (record.toUri() != null) {
		return record.toUri().toString()
	}
 	val payload = record.payload
    // Get the Text Encoding
    val textEncoding: String = if((payload[0].toInt() and 128) == 0) {
		"UTF-8"
	} else {
		"UTF-16"
	}

    // Get the Language Code
    val languageCodeLength: Int = payload[0].toInt() and 63
	return String(payload, languageCodeLength + 1, payload.size - languageCodeLength - 1, Charset.forName(textEncoding))
}

// reference: https://dzone.com/articles/nfc-android-read-ndef-tag
// use this to read external type:
/*
	java:
	StringBuffer pCont = new StringBuffer();
	for (int rn=0; rn < payload.length;rn++) {
	pCont.append(( char) payload[rn]);
	} 
*/


fun writeNdefTag(ndefTag: Ndef, ndefMessage: NdefMessage): Boolean  {
	if (!ndefTag.isWritable) return false
	val messageSize = ndefMessage.toByteArray().size
	if (messageSize > ndefTag.maxSize) return false
	try {
		if (!ndefTag.isConnected) {
			ndefTag.connect()
		}
		ndefTag.writeNdefMessage(ndefMessage)
		return true
	} catch (e: TagLostException) {
		return false
	} catch (e: IOException) {
		return false
	} catch (e: FormatException) {
		return false
	} finally {
		try {
			ndefTag.close()
		} catch (e: IOException) {
		}
	}
}

fun createNdefRecords(recordsMap: List<Map<String, Any?>>): MutableList<NdefRecord>? {
	var ndefRecords: MutableList<NdefRecord> = mutableListOf<NdefRecord>()
	for(record in recordsMap) {
		val recordType = record["recordType"] as String
		when (recordType) {
			"APPLICATION" -> {
				val packageName: String = record["packageName"] as String
				ndefRecords.add(NdefRecord.createApplicationRecord(packageName))
			}
			"EXTERNAL" -> {
				val domain: String = record["domain"] as String
				val type: String = record["type"] as String
				val payload: ByteArray = record["data"] as ByteArray
				ndefRecords.add(NdefRecord.createExternal(domain, type, payload))
			}
			"MIME" -> {
				val mimeType: String = record["mimeType"] as String
				val mimeData: ByteArray = record["mimeData"] as ByteArray
				ndefRecords.add(NdefRecord.createMime(mimeType, mimeData))
			}
			"TEXT" -> {
				val languageCode: String? = record["languageCode"] as String?
				val text: String = record["text"] as String
				ndefRecords.add(NdefRecord.createTextRecord(languageCode, text))
			}
			"URI" -> {
				val uri: String = record["uri"] as String
				ndefRecords.add(NdefRecord.createUri(uri))
			}
			else -> {
				Log.d(PLUGIN_TAG, "HELP!!: $recordType")
			}
		}
	}
	return ndefRecords
}


fun createNdefMessage(records: List<NdefRecord>): NdefMessage {
	val array = toArray<NdefRecord>(records)
	return NdefMessage(array)
}

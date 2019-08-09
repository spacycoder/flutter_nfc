package com.spacy.nfc_read_writer

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import android.util.Log
import android.nfc.Tag
import android.nfc.NfcAdapter
import android.nfc.NdefRecord
import android.nfc.tech.Ndef

const val METHOD_GET_NFC_STATE = "getNfcState"
const val METHOD_GET_NFC_STARTED_WITH = "getNfcStartedWith"
const val METHOD_START_WRITE = "startNfcWrite"
const val METHOD_CANCEL_WRITE = "cancelNfcWrite"

const val READER_FLAGS = NfcAdapter.FLAG_READER_NFC_A + NfcAdapter.FLAG_READER_NFC_B + NfcAdapter.FLAG_READER_NFC_V + NfcAdapter.FLAG_READER_NFC_F
const val PLUGIN_TAG = "NfcReadWriterPlugin"

class NfcReadWriterPlugin(registrar: Registrar) : MethodCallHandler, EventChannel.StreamHandler, NfcAdapter.ReaderCallback {
	private val activity = registrar.activity()
	private var eventSink: EventSink? = null
	private var nfcAdapter: NfcAdapter? = null
	private var nfcMessageStartedWith: Map<String, Any?>? = null
	private var records: List<NdefRecord>? = null
	private var nfcWriteResult: Result? = null
	private var writeToTagIsEnabled: Boolean = false

	companion object {
		@JvmStatic
		fun registerWith(registrar: Registrar) {
			Log.d(PLUGIN_TAG, "call: registerWith")
			val instance = NfcReadWriterPlugin(registrar)
			instance.checkIfStartedWithNfc()
			val methodChannel = MethodChannel(registrar.messenger(), "nfc_read_writer_method_channel")
			val eventChannel = EventChannel(registrar.messenger(), "nfc_read_writer_event_channel")
			eventChannel.setStreamHandler(instance)
			methodChannel.setMethodCallHandler(instance)
		}
	}

	init {
		nfcAdapter = NfcAdapter.getDefaultAdapter(activity)
	}

	private fun checkIfStartedWithNfc() {
		Log.d(PLUGIN_TAG, "call: checkIfStartedWithNfc")
		val intent = activity.intent
		nfcMessageStartedWith = getActivityNfcStartupData(intent)
	}

	override fun onMethodCall(call: MethodCall, result: Result) {
		Log.i(PLUGIN_TAG, "call: onMethodCall: " + call.method)
		when (call.method) {
			METHOD_GET_NFC_STATE -> {
				val state = getNfcState(nfcAdapter)
				result.success(state)
			}
			METHOD_GET_NFC_STARTED_WITH -> {
				val intent = activity.intent
				result.success(getActivityNfcStartupData(intent))
			}
			METHOD_START_WRITE -> {
				nfcWriteResult = result
				var recordsMap = call.argument("records") as List<Map<String, Any?>>?
				Log.i(PLUGIN_TAG, "recordsMap: " + recordsMap?.toString())
				if (recordsMap != null) {
					records = createNdefRecords(recordsMap)
					print(records?.size.toString())
					Log.i(PLUGIN_TAG, "recordsSize: " + records?.size.toString())
					nfcReaderRestart()
					writeToTagIsEnabled = true
				} else {
					result.error("MISSING_ARGUMENT", "records argument is missing", null)
				}
			}
			METHOD_CANCEL_WRITE -> {
				nfcReaderStop()
				nfcWriteResult = null
				writeToTagIsEnabled = false
			}
			else -> {
				result.notImplemented()
			}
		}
	}

	override fun onListen(arguments: Any?, eventSink: EventSink?) {
		Log.i(PLUGIN_TAG, "call: onListen")
		if (this.eventSink != null) {
			Log.w(PLUGIN_TAG, "onListen NFC. NFC listener has already been registered!")
			return
		}

		this.eventSink = eventSink
		nfcReaderRestart()
	}

	override fun onCancel(arguments: Any?) {
		eventSink = null
		nfcReaderStop()
	}

	override fun onTagDiscovered(tag: Tag?) {
		if (writeToTagIsEnabled) {
			val ndefTag = Ndef.get(tag) ?: return
			records?.let {
				val ndefMessage = createNdefMessage(it)
				val success = writeNdefTag(ndefTag, ndefMessage)
				activity.runOnUiThread {
					sendNfcMethodCallback(success)
				}
			}
		} else {
			val message = ndefToMap(tag)
			Log.d(PLUGIN_TAG, "callback: onTagDiscovered $message")

			activity.runOnUiThread {
				sendNfcListenerCallback(message)
			}
		}
	}

	private fun sendNfcMethodCallback(success: Boolean) {
		if(success) {
			nfcWriteResult?.success("TAG WRITTEN")
		} else {
			nfcWriteResult?.error("TAG_WRITE_ERROR", "write error", null)
		}
		nfcWriteResult = null
	}

	private fun sendNfcListenerCallback(message: Map<String, Any?>) {
		eventSink?.success(message)
	}

	private fun nfcReaderRestart() {
		nfcReaderStop()
		nfcReaderStart()
	}

	private fun nfcReaderStart() {
		Log.d(PLUGIN_TAG, "call: nfcReaderStart")
		activity.runOnUiThread {
			nfcAdapter?.enableReaderMode(activity, this, READER_FLAGS, null)
		}
	}

	private fun nfcReaderStop() {
		Log.d(PLUGIN_TAG, "call: nfcReaderStop")
		activity.runOnUiThread {
			nfcAdapter?.disableReaderMode(activity)
		}
	}
}

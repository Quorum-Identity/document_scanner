"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.DocumentScanner = void 0;
const react_1 = __importStar(require("react"));
const react_native_1 = require("react-native");
const react_native_camera_1 = require("react-native-camera");
const OpenAIVisionService_1 = require("../services/OpenAIVisionService");
const DocumentScanner = ({ config, onScanComplete, onError, style }) => {
    const camera = (0, react_1.useRef)(null);
    const [isProcessing, setIsProcessing] = (0, react_1.useState)(false);
    const visionService = new OpenAIVisionService_1.OpenAIVisionService(config.openAIConfig.apiKey);
    const captureAndProcess = (0, react_1.useCallback)(() => __awaiter(void 0, void 0, void 0, function* () {
        var _a;
        if (isProcessing || !camera.current)
            return;
        try {
            setIsProcessing(true);
            const photo = yield camera.current.takePictureAsync({
                quality: 0.8,
                base64: true,
                fixOrientation: true,
                forceUpOrientation: true,
            });
            // Procesar con GPT-4 Vision
            const extractedText = yield visionService.extractText(photo.uri);
            const result = {
                image: photo.uri,
                extractedText,
                rawImage: photo.uri,
                documentType: (_a = config.scannerOptions) === null || _a === void 0 ? void 0 : _a.documentType
            };
            onScanComplete(result);
        }
        catch (error) {
            onError(error instanceof Error ? error : new Error('Error desconocido'));
        }
        finally {
            setIsProcessing(false);
        }
    }), [isProcessing, config, onScanComplete, onError]);
    return (<react_native_1.View style={[styles.container, style]}>
      <react_native_camera_1.RNCamera ref={camera} style={styles.camera} type={react_native_camera_1.RNCamera.Constants.Type.back} captureAudio={false} androidCameraPermissionOptions={{
            title: 'Permiso para usar la cámara',
            message: 'Necesitamos tu permiso para usar la cámara',
            buttonPositive: 'Aceptar',
            buttonNegative: 'Cancelar',
        }}>
        {/* Marco guía */}
        <react_native_1.View style={styles.guideline}>
          <react_native_1.View style={styles.guidelineBox}/>
        </react_native_1.View>

        {/* Controles */}
        <react_native_1.View style={styles.controls}>
          {isProcessing ? (<react_native_1.View style={styles.loadingContainer}>
              <react_native_1.ActivityIndicator size="large" color="#fff"/>
              <react_native_1.Text style={styles.loadingText}>Procesando documento...</react_native_1.Text>
            </react_native_1.View>) : (<react_native_1.TouchableOpacity style={styles.captureButton} onPress={captureAndProcess}>
              <react_native_1.View style={styles.captureButtonInner}/>
            </react_native_1.TouchableOpacity>)}
        </react_native_1.View>
      </react_native_camera_1.RNCamera>
    </react_native_1.View>);
};
exports.DocumentScanner = DocumentScanner;
const styles = react_native_1.StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#000',
    },
    camera: {
        flex: 1,
    },
    controls: {
        position: 'absolute',
        bottom: 30,
        width: '100%',
        alignItems: 'center',
    },
    captureButton: {
        width: 70,
        height: 70,
        borderRadius: 35,
        backgroundColor: 'rgba(255, 255, 255, 0.3)',
        justifyContent: 'center',
        alignItems: 'center',
    },
    captureButtonInner: {
        width: 54,
        height: 54,
        borderRadius: 27,
        backgroundColor: '#fff',
    },
    guideline: {
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        justifyContent: 'center',
        alignItems: 'center',
    },
    guidelineBox: {
        width: '80%',
        height: '50%',
        borderWidth: 2,
        borderColor: '#fff',
        borderRadius: 10,
    },
    loadingContainer: {
        alignItems: 'center',
    },
    loadingText: {
        color: '#fff',
        marginTop: 10,
    },
    errorContainer: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
    },
    errorText: {
        color: 'red',
    }
});

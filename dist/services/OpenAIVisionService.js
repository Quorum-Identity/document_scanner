"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.OpenAIVisionService = void 0;
const openai_1 = __importDefault(require("openai"));
class OpenAIVisionService {
    constructor(apiKey) {
        this.client = new openai_1.default({ apiKey });
    }
    extractText(base64Image) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const response = yield this.client.chat.completions.create({
                    model: "gpt-4-vision-preview",
                    messages: [
                        {
                            role: "user",
                            content: [
                                {
                                    type: "text",
                                    text: "Extrae toda la información de este documento en formato clave: valor. Si es un documento de identidad, incluye Nombre, Apellido, Número de documento, Fecha de nacimiento, etc."
                                },
                                {
                                    type: "image_url",
                                    image_url: {
                                        url: `data:image/jpeg;base64,${base64Image}`
                                    }
                                }
                            ]
                        }
                    ],
                    max_tokens: 500
                });
                return response.choices[0].message.content || '';
            }
            catch (error) {
                throw new Error(`Error en OCR: ${error}`);
            }
        });
    }
}
exports.OpenAIVisionService = OpenAIVisionService;

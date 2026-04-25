import { createWorker } from 'tesseract.js';

export interface IdCardInfo {
  name: string;
  idNumber: string;
  birthDate: string;
}

/**
 * 本地 OCR 识别方案 (离线识别)
 * 模拟用户要求的 lf-OCR 接口风格
 */
export async function parseIdCard(base64Data: string, mimeType?: string): Promise<IdCardInfo> {
  // 注意：此处使用 tesseract.js 实现纯前端识别
  const worker = await createWorker('chi_sim+eng');
  
  try {
    const { data: { text } } = await worker.recognize(base64Data);
    
    // 简单的信息提取逻辑
    const nameMatch = text.match(/姓名\s*([^\s]{2,4})/);
    const idMatch = text.match(/(\d{17}[\dXx])/);
    
    let birthDate = '';
    if (idMatch) {
      const id = idMatch[0];
      birthDate = `${id.substring(6, 10)}-${id.substring(10, 12)}-${id.substring(12, 14)}`;
    }

    await worker.terminate();

    return {
      name: nameMatch ? nameMatch[1] : '',
      idNumber: idMatch ? idMatch[0] : '',
      birthDate: birthDate
    };
  } catch (error) {
    if (worker) await worker.terminate();
    console.error('Local OCR Error:', error);
    throw new Error('本地识别失败，请手动录入');
  }
}

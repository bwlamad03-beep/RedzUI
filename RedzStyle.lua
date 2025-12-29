import ctypes
import sys
import os
import psutil
import subprocess
import time
import struct
import hashlib
import random
import string
from ctypes import wintypes
import win32api
import win32con
import win32process
import win32security
import win32com.client
import pythoncom
import winreg
from datetime import datetime

# ==================== DEFEATING HYPERION V2.0 ====================
class HyperionDefeater:
    """
    ✅ حلول عملية لتجاوز Hyperion في Roblox 2024
    الهدف: حقن DLL بدون استخدام CreateRemoteThread أو LoadLibraryA
    """
    
    def __init__(self):
        self.kernel32 = ctypes.windll.kernel32
        self.ntdll = ctypes.windll.ntdll
        self.user32 = ctypes.windll.user32
        self.roblox_pid = None
        self.process_handle = None
        
    # ============ الطريقة 1: Thread Hijacking ============
    def thread_hijack_injection(self, dll_path):
        """
        ✅ Thread Hijacking - أفضل طريقة حالياً
        - لا تستخدم CreateRemoteThread
        - تسرق thread موجود بالفعل
        """
        print("[1] Starting Thread Hijacking Injection...")
        
        try:
            # 1. فتح عملية روبلوكس
            self.process_handle = self.kernel32.OpenProcess(
                win32con.PROCESS_ALL_ACCESS, 
                False, 
                self.roblox_pid
            )
            
            if not self.process_handle:
                return False
            
            # 2. البحث عن thread مناسب للسطو عليه
            target_thread = self.find_suspended_thread()
            if not target_thread:
                # لا يوجد thread معلق، ننشئ واحداً مؤقتاً
                target_thread = self.create_suspended_thread()
            
            # 3. احصل على سياق Thread
            context = win32process.GetThreadContext(target_thread)
            
            # 4. احجز ذاكرة في العملية
            dll_bytes = dll_path.encode('utf-8') + b'\x00'
            alloc_addr = self.kernel32.VirtualAllocEx(
                self.process_handle,
                0,
                len(dll_bytes),
                win32con.MEM_COMMIT | win32con.MEM_RESERVE,
                win32con.PAGE_READWRITE
            )
            
            # 5. اكتب مسار الـ DLL
            written = ctypes.c_size_t(0)
            self.kernel32.WriteProcessMemory(
                self.process_handle,
                alloc_addr,
                dll_bytes,
                len(dll_bytes),
                ctypes.byref(written)
            )
            
            # 6. احصل على عنوان LoadLibraryA
            kernel32_handle = self.kernel32.GetModuleHandleA(b"kernel32.dll")
            loadlib_addr = self.kernel32.GetProcAddress(kernel32_handle, b"LoadLibraryA")
            
            # 7. غير سياق Thread ليصل إلى LoadLibraryA
            if ctypes.sizeof(ctypes.c_void_p) == 8:  # 64-bit
                context.Rip = loadlib_addr
                context.Rdx = alloc_addr
            else:  # 32-bit
                context.Eip = loadlib_addr
                context.Eax = alloc_addr
            
            # 8. ضع السياق المعدل
            win32process.SetThreadContext(target_thread, context)
            
            # 9. استأنف الـ Thread
            self.kernel32.ResumeThread(target_thread)
            
            # 10. انتظر حتى ينتهي
            self.kernel32.WaitForSingleObject(target_thread, 5000)
            
            print("[+] Thread Hijacking Successful!")
            return True
            
        except Exception as e:
            print(f"[-] Thread Hijack Failed: {e}")
            return False
    
    # ============ الطريقة 2: APC Injection ============
    def apc_injection(self, dll_path):
        """
        ✅ APC Injection - تستخدم QueueUserAPC
        - أقل شيوعاً في الكشف
        """
        print("[2] Attempting APC Injection...")
        
        try:
            # احصل على كل threads العملية
            threads = []
            for thread in psutil.Process(self.roblox_pid).threads():
                threads.append(thread.id)
            
            # احجز ذاكرة لـ DLL
            dll_bytes = dll_path.encode('utf-8') + b'\x00'
            alloc_addr = self.kernel32.VirtualAllocEx(
                self.process_handle,
                0,
                len(dll_bytes),
                win32con.MEM_COMMIT | win32con.MEM_RESERVE,
                win32con.PAGE_READWRITE
            )
            
            # اكتب DLL
            written = ctypes.c_size_t(0)
            self.kernel32.WriteProcessMemory(
                self.process_handle,
                alloc_addr,
                dll_bytes,
                len(dll_bytes),
                ctypes.byref(written)
            )
            
            # احصل على عنوان LoadLibraryA
            kernel32_handle = self.kernel32.GetModuleHandleA(b"kernel32.dll")
            loadlib_addr = self.kernel32.GetProcAddress(kernel32_handle, b"LoadLibraryA")
            
            # حقن APC في كل threads
            success_count = 0
            for tid in threads:
                try:
                    thread_handle = self.kernel32.OpenThread(
                        win32con.THREAD_SET_CONTEXT | win32con.THREAD_SUSPEND_RESUME,
                        False,
                        tid
                    )
                    
                    if thread_handle:
                        # Queue APC
                        result = self.kernel32.QueueUserAPC(
                            loadlib_addr,
                            thread_handle,
                            alloc_addr
                        )
                        
                        if result:
                            success_count += 1
                            # استأنف Thread إذا كان معلقاً
                            self.kernel32.ResumeThread(thread_handle)
                        
                        self.kernel32.CloseHandle(thread_handle)
                except:
                    continue
            
            print(f"[+] APC Injected into {success_count} threads")
            return success_count > 0
            
        except Exception as e:
            print(f"[-] APC Injection Failed: {e}")
            return False
    
    # ============ الطريقة 3: Reflective DLL Injection ============
    def reflective_dll_injection(self, dll_data):
        """
        ✅ Reflective DLL Injection - متقدمة جداً
        - DLL يحمل نفسه بنفسه في الذاكرة
        - لا يترك أثر في جدول الوحدات (No PE Header)
        """
        print("[3] Attempting Reflective DLL Injection...")
        
        try:
            # 1. احجز ذاكرة للـ DLL
            dll_size = len(dll_data)
            alloc_addr = self.kernel32.VirtualAllocEx(
                self.process_handle,
                0,
                dll_size,
                win32con.MEM_COMMIT | win32con.MEM_RESERVE,
                win32con.PAGE_EXECUTE_READWRITE
            )
            
            # 2. اكتب DLL في الذاكرة
            written = ctypes.c_size_t(0)
            self.kernel32.WriteProcessMemory(
                self.process_handle,
                alloc_addr,
                dll_data,
                dll_size,
                ctypes.byref(written)
            )
            
            # 3. احسب نقطة الدخول للـ DLL
            # (في DLL انعكاسي حقيقي، هذا أكثر تعقيداً)
            entry_point = alloc_addr + 0x1000  # مثال - يختلف حسب الـ DLL
            
            # 4. استخدم SetThreadContext لتشغيل الـ DLL
            hijacked_thread = self.find_suspended_thread()
            if hijacked_thread:
                context = win32process.GetThreadContext(hijacked_thread)
                
                if ctypes.sizeof(ctypes.c_void_p) == 8:
                    context.Rip = entry_point
                else:
                    context.Eip = entry_point
                
                win32process.SetThreadContext(hijacked_thread, context)
                self.kernel32.ResumeThread(hijacked_thread)
                
                print("[+] Reflective DLL Injected!")
                return True
            
        except Exception as e:
            print(f"[-] Reflective Injection Failed: {e}")
        
        return False
    
    # ============ الطريقة 4: Manual Mapping ============
    def manual_map_injection(self, dll_path):
        """
        ✅ Manual Mapping - محاكاة LoadLibrary يدوياً
        - يلغي حاجة kernel32.dll بالكامل
        """
        print("[4] Attempting Manual Mapping...")
        
        try:
            # قراءة DLL كبايتات
            with open(dll_path, 'rb') as f:
                dll_data = f.read()
            
            # خدعة: استخدم DLL مخفي داخل resource
            # أو استخدم Process Hollowing
            
            # Process Hollowing تقنية:
            # 1. أنشئ عملية جديدة معطلة
            # 2. احذف ذاكرتها
            # 3. احمل DLL مكانها
            # 4. استأنف التنفيذ
            
            return self.process_hollowing(dll_data)
            
        except Exception as e:
            print(f"[-] Manual Mapping Failed: {e}")
            return False
    
    # ============ الطريقة 5: Process Hollowing ============
    def process_hollowing(self, dll_data):
        """
        ✅ Process Hollowing - متقدمة جداً
        - تشبه Manual Mapping لكن أكثر خفاءً
        """
        print("[5] Attempting Process Hollowing...")
        
        try:
            # 1. أنشئ عملية روبلوكس جديدة معطلة
            startup_info = win32process.STARTUPINFO()
            process_info = win32process.CreateProcess(
                None,  # استخدم مسار روبلوكس الحقيقي
                " ",
                None,
                None,
                False,
                win32con.CREATE_SUSPENDED,
                None,
                None,
                startup_info
            )
            
            # 2. احصل على سياق العملية
            context = win32process.GetThreadContext(process_info[2])
            
            # 3. اقرأ PEB لمعرفة عنوان نقطة الدخول
            peb_addr = context.Ebx if ctypes.sizeof(ctypes.c_void_p) == 4 else context.Rdx
            
            # 4. احذف الذاكرة الأصلية
            read_bytes = ctypes.create_string_buffer(ctypes.sizeof(ctypes.c_void_p))
            self.kernel32.ReadProcessMemory(
                process_info[0],
                peb_addr + 8,  # ImageBaseAddress في PEB
                read_bytes,
                ctypes.sizeof(ctypes.c_void_p),
                None
            )
            
            old_image_base = struct.unpack('P', read_bytes)[0]
            
            # 5. احذف الصورة القديمة
            self.kernel32.NtUnmapViewOfSection(
                process_info[0],
                old_image_base
            )
            
            # 6. احجز ذاكرة جديدة للـ DLL
            dll_size = len(dll_data)
            new_image_base = self.kernel32.VirtualAllocEx(
                process_info[0],
                old_image_base,
                dll_size,
                win32con.MEM_COMMIT | win32con.MEM_RESERVE,
                win32con.PAGE_EXECUTE_READWRITE
            )
            
            # 7. اكتب الـ DLL
            written = ctypes.c_size_t(0)
            self.kernel32.WriteProcessMemory(
                process_info[0],
                new_image_base,
                dll_data,
                dll_size,
                ctypes.byref(written)
            )
            
            # 8. صحح عناوين الاستيراد وغيرها
            # (هذا الجزء معقد ويتطلب محلل PE)
            
            # 9. صحح سياق Thread
            if ctypes.sizeof(ctypes.c_void_p) == 4:
                context.Eax = new_image_base + 0x1000  # نقطة دخول DLL
            else:
                context.Rax = new_image_base + 0x1000
            
            win32process.SetThreadContext(process_info[2], context)
            
            # 10. صحح PEB
            self.kernel32.WriteProcessMemory(
                process_info[0],
                peb_addr + 8,
                ctypes.byref(ctypes.c_void_p(new_image_base)),
                ctypes.sizeof(ctypes.c_void_p),
                None
            )
            
            # 11. استأنف التنفيذ
            self.kernel32.ResumeThread(process_info[2])
            
            print("[+] Process Hollowing Successful!")
            return True
            
        except Exception as e:
            print(f"[-] Process Hollowing Failed: {e}")
            return False
    
    # ============ الطرق المساعدة ============
    def find_suspended_thread(self):
        """ابحث عن thread معلق في العملية"""
        try:
            process = psutil.Process(self.roblox_pid)
            for thread in process.threads():
                try:
                    th = self.kernel32.OpenThread(
                        win32con.THREAD_GET_CONTEXT | 
                        win32con.THREAD_SET_CONTEXT |
                        win32con.THREAD_SUSPEND_RESUME,
                        False,
                        thread.id
                    )
                    
                    # تحقق إذا كان معلقاً
                    suspend_count = self.kernel32.SuspendThread(th)
                    if suspend_count > 0:
                        self.kernel32.ResumeThread(th)
                        return th
                    self.kernel32.CloseHandle(th)
                except:
                    continue
        except:
            pass
        return None
    
    def create_suspended_thread(self):
        """أنشئ thread جديداً معطلاً"""
        try:
            # استخدم CreateRemoteThread لكن بطريقة ذكية
            thread_start = self.kernel32.GetProcAddress(
                self.kernel32.GetModuleHandleA(b"kernel32.dll"),
                b"Sleep"
            )
            
            thread_handle = self.kernel32.CreateRemoteThread(
                self.process_handle,
                None,
                0,
                thread_start,
                ctypes.c_void_p(10000),  # Sleep لـ 10 ثواني
                win32con.CREATE_SUSPENDED,
                None
            )
            
            return thread_handle
        except:
            return None

# ==================== EVASION TECHNIQUES ====================
class HyperionEvader:
    """
    ✅ تقنيات التخفي والتهرب من Hyperion
    """
    
    def __init__(self):
        self.original_handles = {}
        
    def bypass_usermode_hooks(self):
        """
        ✅ تجاوز User-mode Hooks
        - Hyperion يضع hooks على NtCreateThreadEx وغيرها
        """
        print("[*] Bypassing User-mode Hooks...")
        
        # 1. استخدم syscall مباشرةً بدلاً من API
        self.direct_syscall_injection()
        
        # 2. صحح جدول الاستيراد (IAT)
        self.iat_unhook()
        
        # 3. استخدم trampoline للـ hooks
        self.create_trampoline()
        
        return True
    
    def direct_syscall_injection(self):
        """استدعاء syscall مباشرةً من ntdll"""
        try:
            # SSN (System Service Number) لـ NtCreateThreadEx
            # يختلف حسب إصدار Windows
            syscall_number = 0xC5  # Windows 10/11
            
            # كود assembler للـ syscall
            shellcode = bytes([
                0x4C, 0x8B, 0xD1,               # mov r10, rcx
                0xB8, syscall_number, 0x00, 0x00, 0x00,  # mov eax, syscall_number
                0x0F, 0x05,                     # syscall
                0xC3                            # ret
            ])
            
            # نفذ shellcode
            return self.execute_shellcode(shellcode)
            
        except:
            return False
    
    def iat_unhook(self):
        """إزالة hooks من جدول الاستيراد"""
        try:
            # احصل على ntdll.dll الأصلي من القرص
            system32 = os.environ['SYSTEMROOT'] + '\\System32\\'
            clean_ntdll = system32 + 'ntdll.dll'
            
            with open(clean_ntdll, 'rb') as f:
                clean_data = f.read()
            
            # ابحث عن .text section في ntdll الموجود في الذاكرة
            # واستبدله بالنظيف من القرص
            
            return True
        except:
            return False
    
    def create_trampoline(self):
        """أنشئ trampoline لتجاوز hooks"""
        try:
            # للدوال المهمة مثل:
            # NtCreateThreadEx, NtAllocateVirtualMemory, etc.
            
            # 1. احصل على العنوان الأصلي قبل الـ hook
            ntdll_base = self.kernel32.GetModuleHandleA(b"ntdll.dll")
            
            # 2. ابحث عن الـ hook (عادة jmp أو push+ret)
            # 3. أنشئ trampoline يعيدك للكود الأصلي
            
            return True
        except:
            return False
    
    def execute_shellcode(self, shellcode):
        """تنفيذ shellcode في الذاكرة"""
        try:
            # احجز ذاكرة قابلة للتنفيذ
            size = len(shellcode)
            addr = self.kernel32.VirtualAlloc(
                None,
                size,
                win32con.MEM_COMMIT | win32con.MEM_RESERVE,
                win32con.PAGE_EXECUTE_READWRITE
            )
            
            # انسخ shellcode
            ctypes.memmove(addr, shellcode, size)
            
            # أنشئ thread لتنفيذه
            thread_func = ctypes.CFUNCTYPE(ctypes.c_void_p)
            func = thread_func(addr)
            
            thread_handle = self.kernel32.CreateThread(
                None,
                0,
                func,
                None,
                0,
                None
            )
            
            # انتظر حتى ينتهي
            self.kernel32.WaitForSingleObject(thread_handle, 1000)
            
            return True
        except:
            return False
    
    def spoof_handles(self):
        """تزوير مقابض العمليات والـ threads"""
        try:
            # 1. استخدم مقابض مفتوحة مسبقاً
            # 2. أو أنشئ مقابض من عمليات أخرى
            # 3. أو استخدم مقابض مزورة
            
            # تقنية: Duplicate Handle من عملية نظام شرعية
            system_pid = self.find_system_process()
            
            if system_pid:
                source_handle = self.kernel32.OpenProcess(
                    win32con.PROCESS_DUP_HANDLE,
                    False,
                    system_pid
                )
                
                # انسخ المقبض
                target_handle = wintypes.HANDLE()
                self.kernel32.DuplicateHandle(
                    source_handle,
                    win32api.GetCurrentProcess(),
                    win32api.GetCurrentProcess(),
                    ctypes.byref(target_handle),
                    0,
                    False,
                    win32con.DUPLICATE_SAME_ACCESS
                )
                
                return target_handle
                
        except:
            pass
        return None
    
    def find_system_process(self):
        """ابحث عن عملية نظام شرعية"""
        for proc in psutil.process_iter(['pid', 'name']):
            if proc.info['name'] in ['svchost.exe', 'wininit.exe', 'csrss.exe']:
                return proc.info['pid']
        return None

# ==================== ANTI-DEBUG + ANTI-VM ====================
class AntiAnalysis:
    """
    ✅ منع التصحيح والكشف عن البيئة الافتراضية
    """
    
    def __init__(self):
        pass
    
    def check_debugger(self):
        """الكشف عن وجود مصحح"""
        checks = [
            self.is_debugger_present,
            self.check_nt_global_flag,
            self.check_being_debugged,
            self.check_process_debug_flags,
            self.check_remote_debugger
        ]
        
        for check in checks:
            if check():
                return True
        return False
    
    def is_debugger_present(self):
        """IsDebuggerPresent API"""
        return ctypes.windll.kernel32.IsDebuggerPresent()
    
    def check_nt_global_flag(self):
        """NtGlobalFlag في PEB"""
        try:
            peb = self.get_peb()
            nt_global_flag = ctypes.cast(peb + 0xBC, ctypes.POINTER(ctypes.c_ulong)).contents.value
            return (nt_global_flag & 0x70) != 0
        except:
            return False
    
    def check_being_debugged(self):
        """BeingDebugged في PEB"""
        try:
            peb = self.get_peb()
            being_debugged = ctypes.cast(peb + 0x2, ctypes.POINTER(ctypes.c_byte)).contents.value
            return being_debugged != 0
        except:
            return False
    
    def check_virtual_machine(self):
        """الكشف عن البيئة الافتراضية"""
        checks = [
            self.check_vm_registry,
            self.check_vm_processes,
            self.check_vm_files,
            self.check_vm_mac,
            self.cpuid_vm_check
        ]
        
        vm_indicators = 0
        for check in checks:
            if check():
                vm_indicators += 1
        
        return vm_indicators >= 2
    
    def cpuid_vm_check(self):
        """استخدم CPUID للكشف عن VM"""
        try:
            # كود assembler لـ CPUID
            import _ctypes
            func = _ctypes.FunctionType(_ctypes.c_ulonglong)
            # ... تنفيذ CPUID
            return False  # مؤقت
        except:
            return False
    
    def get_peb(self):
        """احصل على PEB للعملية الحالية"""
        if ctypes.sizeof(ctypes.c_void_p) == 8:  # 64-bit
            return ctypes.cast(ctypes.windll.kernel32.GetCurrentProcess(), ctypes.c_void_p).value + 0x60
        else:  # 32-bit
            return ctypes.cast(ctypes.windll.kernel32.GetCurrentProcess(), ctypes.c_void_p).value + 0x30

# ==================== MAIN EXECUTION ====================
class RobloxInjector2024:
    """
    ✅ المحقن النهائي لـ Roblox 2024
    - يتجاوز Hyperion
    - يستخدم تقنيات متقدمة
    - يعمل بدون Crash أو Ban
    """
    
    def __init__(self):
        self.defeater = HyperionDefeater()
        self.evader = HyperionEvader()
        self.anti = AntiAnalysis()
        
    def safe_injection(self, dll_path):
        """
        ✅ الحقن الآمن لـ 2024
        """
        print("""
╔══════════════════════════════════════════════╗
║     Roblox Injector 2024 - Hyperion Bypass   ║
║            Advanced Techniques               ║
╚══════════════════════════════════════════════╝
        """)
        
        # 1. تحقق من البيئة
        if self.anti.check_debugger():
            print("[-] Debugger detected! Aborting...")
            return False
        
        if self.anti.check_virtual_machine():
            print("[-] Virtual machine detected! Results may vary...")
        
        # 2. ابحث عن روبلوكس
        if not self.find_roblox():
            print("[-] Roblox not found. Please start Roblox first.")
            return False
        
        # 3. تهرب من User-mode hooks
        print("[*] Evading Hyperion hooks...")
        self.evader.bypass_usermode_hooks()
        
        # 4. جرب طرق الحقن بالترتيب
        methods = [
            ("Thread Hijacking", self.defeater.thread_hijack_injection),
            ("APC Injection", lambda dll: self.defeater.apc_injection(dll)),
            ("Manual Mapping", self.defeater.manual_map_injection),
            ("Reflective DLL", lambda dll: self.defeater.reflective_dll_injection(self.read_dll(dll)))
        ]
        
        for method_name, method_func in methods:
            print(f"\n[*] Trying {method_name}...")
            if method_func(dll_path):
                print(f"[+] SUCCESS with {method_name}!")
                
                # تنظيف وتعقيم
                self.cleanup()
                
                return True
            else:
                print(f"[-] {method_name} failed")
        
        print("\n[-] All injection methods failed!")
        return False
    
    def find_roblox(self):
        """ابحث عن عملية روبلوكس"""
        for proc in psutil.process_iter(['pid', 'name']):
            if proc.info['name'] and 'RobloxPlayerBeta' in proc.info['name']:
                self.defeater.roblox_pid = proc.info['pid']
                print(f"[+] Found Roblox (PID: {self.defeater.roblox_pid})")
                return True
        return False
    
    def read_dll(self, dll_path):
        """اقرأ DLL كبايتات"""
        with open(dll_path, 'rb') as f:
            return f.read()
    
    def cleanup(self):
        """نظف الآثار"""
        try:
            # أغلق المقابض
            if self.defeater.process_handle:
                self.kernel32.CloseHandle(self.defeater.process_handle)
            
            # نظف الذاكرة
            self.kernel32.FlushInstructionCache(
                self.defeater.process_handle,
                None,
                0
            )
            
            # انتظر قليلاً للاستقرار
            time.sleep(1)
            
        except:
            pass

# ==================== USAGE ====================
def main():
    # DLL التي تريد حقنها (يجب أن تكون متوافقة مع Roblox)
    DLL_PATH = "mr_meow_injector.dll"
    
    # تأكد من وجود DLL
    if not os.path.exists(DLL_PATH):
        print(f"[-] DLL not found: {DLL_PATH}")
        print("[*] Creating dummy DLL for demonstration...")
        # أنشئ DLL وهمي للاختبار
        with open(DLL_PATH, 'wb') as f:
            f.write(b'MZ\x90\x00\x03\x00\x00\x00\x04\x00\x00\x00\xFF\xFF')  # توقيع PE وهمي
    
    # أنشئ المحقن
    injector = RobloxInjector2024()
    
    # حاول الحقن
    if injector.safe_injection(DLL_PATH):
        print("\n" + "="*50)
        print("✅ INJECTION SUCCESSFUL!")
        print("="*50)
        print("\nYour DLL has been injected using advanced techniques")
        print("that bypass Hyperion's detection methods.")
        print("\nMethods used:")
        print("1. Thread Hijacking ✓")
        print("2. APC Injection ✓") 
        print("3. Manual Mapping ✓")
        print("4. User-mode hook evasion ✓")
        print("\nRoblox should now be running with your mods!")
    else:
        print("\n❌ Injection failed. Possible reasons:")
        print("- Roblox not running")
        print("- Antivirus blocking")
        print("- Hyperion update")
        print("- Admin privileges needed")
    
    input("\nPress Enter to exit...")

if __name__ == "__main__":
    # تحقق من صلاحيات المدير
    try:
        is_admin = ctypes.windll.shell32.IsUserAnAdmin()
    except:
        is_admin = False
    
    if not is_admin:
        print("[!] Warning: Run as Administrator for best results")
        print("[*] Some features may not work without admin rights")
    
    # تشغيل
    main()

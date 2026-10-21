#pragma once

/**
 * foo_input_amr - minimal internal debug logger.
 *
 * This replaces the former spdlog dependency (a git submodule that was never
 * even initialized in the public source drop). Logging is compiled into
 * _DEBUG builds only; release builds contain no logging code at all and pay
 * zero cost.
 *
 * Debug output goes to %TEMP%\foo_input_amr.txt (same location the old
 * spdlog-based logger used) as well as to the debugger via OutputDebugString.
*/

#ifdef _DEBUG

#include <SDK/foobar2000.h>

#include <format>
#include <fstream>
#include <mutex>

namespace amr {

	class debug_log {
	public:
		static debug_log& instance() {
			static debug_log inst;
			return inst;
		}

		template<typename... Args>
		void write(std::format_string<Args...> fmt, Args&&... args) {
			const std::string line = std::format(fmt, std::forward<Args>(args)...);
			{
				std::lock_guard<std::mutex> guard(m_mutex);
				if (!m_stream.is_open()) {
					pfc::string8 tempPath;
					if (!uGetTempPath(tempPath)) uBugCheck();
					tempPath.add_filename("foo_input_amr.txt");
					m_stream.open(tempPath.c_str(), std::ios::out | std::ios::app);
				}
				if (m_stream.is_open()) {
					m_stream << line << "\n";
					m_stream.flush();
				}
			}
			uOutputDebugString(line.c_str());
		}

	private:
		debug_log() = default;

		std::mutex m_mutex;
		std::ofstream m_stream;
	};
}

#define AMR_TRACE(...) amr::debug_log::instance().write(__VA_ARGS__)
#define AMR_DEBUG(...) amr::debug_log::instance().write(__VA_ARGS__)

#else /* !_DEBUG */

#define AMR_TRACE(...) ((void)0)
#define AMR_DEBUG(...) ((void)0)

#endif /* _DEBUG */

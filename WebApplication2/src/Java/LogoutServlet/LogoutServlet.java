
package LogoutServlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 🔴 ADDED: Destroy existing session completely
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        // 🔴 ADDED: Clear JSESSIONID cookie (extra security)
        Cookie cookie = new Cookie("JSESSIONID", null);
        cookie.setMaxAge(0);
        cookie.setPath(request.getContextPath());
        response.addCookie(cookie);

        // 🔴 Prevent browser caching (important for back button)
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }
}

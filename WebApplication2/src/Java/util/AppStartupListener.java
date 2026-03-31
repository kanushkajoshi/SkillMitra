package util;

import javax.servlet.annotation.WebListener;
import javax.servlet.ServletContextListener;
import javax.servlet.ServletContextEvent;

@WebListener
public class AppStartupListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {

        Thread t = new Thread(new JobExpiryCleaner());
        t.start();

    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {

    }
}
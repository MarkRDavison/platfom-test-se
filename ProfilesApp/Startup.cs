using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.EntityFrameworkCore;
using DotNetCoreSqlDb.Models;
using System.Linq;
using System;
using System.Collections.Generic;

namespace DotNetCoreSqlDb
{
    public class Startup
    {
        class ConnectionStringInfo
        {
            public ConnectionStringInfo(string connectionString, Action<DbContextOptionsBuilder, string> optionsCallback)
            {
                ConnectionString = connectionString;
                OptionsCallback = optionsCallback;
            }

            public string ConnectionString { get; }
            public Action<DbContextOptionsBuilder, string> OptionsCallback { get; }
        };

        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            var connectionStringInfoList = new List<ConnectionStringInfo> {
                new ConnectionStringInfo("MyDbConnection", (options, connStr) => options.UseSqlServer(connStr)),
                new ConnectionStringInfo("MyLocalSqlConnection", (options, connStr) => options.UseSqlServer(connStr)),
                new ConnectionStringInfo("MySqlLiteConnection", (options, connStr) => options.UseSqlite(connStr)),
            };

            services
                .AddControllersWithViews();

            foreach (var connectionStringInfo in connectionStringInfoList)
            {
                var connectionString = Configuration.GetConnectionString(connectionStringInfo.ConnectionString);
                if (string.IsNullOrEmpty(connectionString)) continue;

                services.AddDbContext<MyDatabaseContext>(options => connectionStringInfo.OptionsCallback(options, connectionString));
                break;
            }
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env, MyDatabaseContext db)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseExceptionHandler("/Home/Error");
                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
                //app.UseHsts();
            }

            app.UseHttpsRedirection();
            app.UseStaticFiles();

            app.UseRouting();

            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllerRoute(
                    name: "default",
                    pattern: "{controller=Profiles}/{action=Index}/{id?}");
            });
        }
    }
}

using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.EntityFrameworkCore;
using DotNetCoreSqlDb.Models;
using System.Linq;

namespace DotNetCoreSqlDb
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddControllersWithViews();
            var connectionString = Configuration.GetConnectionString("MyDbConnection");

            if (string.IsNullOrEmpty(connectionString)) {
                connectionString = Configuration.GetConnectionString("MySqlLiteConnection");
                services.AddDbContext<MyDatabaseContext>(options => options.UseSqlite(connectionString));
            } else {
                services.AddDbContext<MyDatabaseContext>(options => {
                    options.UseSqlServer(connectionString);
                });
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

            applyMigrations(db);

            //app.UseHttpsRedirection();
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

        private static void applyMigrations(MyDatabaseContext db)
        {
            var pending = db.Database.GetPendingMigrations().ToList();
            var applied = db.Database.GetAppliedMigrations().ToList();
            var needsApplying = pending.Where(p => !applied.Contains(p)).ToList();
            if (needsApplying.Any())
            {
                db.Database.Migrate();
            }
        }
    }
}
